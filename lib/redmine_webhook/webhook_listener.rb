module RedmineWebhook
  class WebhookListener < Redmine::Hook::Listener

    def skip_webhooks(context)
      return true unless context[:request]
      return true if context[:request].headers['X-Skip-Webhooks']

      false
    end

    def controller_issues_new_after_save(context = {})
      return if skip_webhooks(context)
      issue = context[:issue]
      controller = context[:controller]
      project = issue.project
      webhooks = RedmineWebhook::Hook.where(:project_id => project.project.id)
      webhooks = RedmineWebhook::Hook.where(:project_id => 0) unless webhooks && webhooks.length > 0
      return unless webhooks
      post(webhooks, issue_to_json(issue, controller))
    end

    def controller_issues_edit_after_save(context = {})
      return if skip_webhooks(context)
      journal = context[:journal]
      controller = context[:controller]
      issue = context[:issue]
      project = issue.project
      webhooks = RedmineWebhook::Hook.where(:project_id => project.project.id)
      webhooks = RedmineWebhook::Hook.where(:project_id => 0) unless webhooks && webhooks.length > 0
      return unless webhooks
      post(webhooks, journal_to_json(issue, journal, controller))
    end

    def controller_issues_bulk_edit_after_save(context = {})
      return if skip_webhooks(context)
      journal = context[:journal]
      controller = context[:controller]
      issue = context[:issue]
      project = issue.project
      webhooks = RedmineWebhook::Hook.where(:project_id => project.project.id)
      webhooks = RedmineWebhook::Hook.where(:project_id => 0) unless webhooks && webhooks.length > 0
      return unless webhooks
      post(webhooks, journal_to_json(issue, journal, controller))
    end

    def model_changeset_scan_commit_for_issue_ids_pre_issue_update(context = {})
      issue = context[:issue]
      journal = issue.current_journal
      webhooks = RedmineWebhook::Hook.where(:project_id => issue.project.project.id)
      webhooks = RedmineWebhook::Hook.where(:project_id => 0) unless webhooks && webhooks.length > 0
      return unless webhooks
      post(webhooks, journal_to_json(issue, journal, nil))
    end

    private
    def issue_to_json(issue, controller)
      {
        :payload => {
          :action => 'opened',
          :issue => RedmineWebhook::IssueWrapper.new(issue).to_hash,
          :url => controller.issue_url(issue)
        }
      }.to_json
    end

    def journal_to_json(issue, journal, controller)
      {
        :payload => {
          :action => 'updated',
          :issue => RedmineWebhook::IssueWrapper.new(issue).to_hash,
          :journal => RedmineWebhook::JournalWrapper.new(journal).to_hash,
          :url => controller.nil? ? 'not yet implemented' : controller.issue_url(issue)
        }
      }.to_json
    end

    def post(webhooks, request_body)
      # Carrega os registros aqui: dentro da thread não há conexão do banco
      # garantida (Rails 7+ devolve a conexão ao pool por executor).
      targets = webhooks.map { |w| [w.url, w.headers] }
      return if targets.empty?

      Thread.start do
        targets.each do |url, headers|
          begin
            Faraday.post do |req|
              req.url url
              req.headers['Content-Type'] = 'application/json'
              if headers.present?
                headers.split("\n").each do |header|
                  header_name, header_value = header.split(":", 2)
                  next if header_name.blank? || header_value.nil?

                  req.headers[header_name.strip] = header_value.strip
                end
              end
              req.body = request_body
            end
          rescue => e
            Rails.logger.error e
          end
        end
      end
    end
  end
end

if Rails.try(:autoloaders).try(:zeitwerk_enabled?)
  Rails.autoloaders.main.push_dir File.dirname(__FILE__) + '/lib/redmine_webhook'
  RedmineWebhook::ProjectsHelperPatch
  RedmineWebhook::WebhookListener
else
  require "redmine_webhook"
end

Redmine::Plugin.register :redmine_webhook do
  name 'Redmine Webhook plugin'
  author 'Luiz Jr'
  description 'A Redmine plugin posts webhook on creating and updating tickets'
  version '0.0.6'
  url 'https://github.com/luizjr/redmine_webhook'
  author_url 'https://luizjr.dev'
  project_module :webhooks do
    permission :manage_hook, {:webhook_settings => [:index, :show, :update, :create, :destroy]}, :require => :member
  end
end

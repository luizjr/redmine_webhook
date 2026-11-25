# frozen_string_literal: true

module RedmineWebhook
  # Webhook do plugin (um por projeto, com cabeçalhos livres).
  # A partir do Redmine 7 o núcleo tem o próprio model Webhook e a tabela
  # "webhooks"; por isso o do plugin vive em RedmineWebhook::Hook e na
  # tabela "redmine_webhooks".
  class Hook < ActiveRecord::Base
    self.table_name = 'redmine_webhooks'

    belongs_to :project
  end
end

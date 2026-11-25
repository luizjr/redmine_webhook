# Redmine 6+ põe lib/ e app/ do plugin no Zeitwerk sozinho e roda este arquivo
# dentro do to_prepare; referenciar as constantes registra o listener e o patch.
RedmineWebhook::ProjectsHelperPatch
RedmineWebhook::WebhookListener

Redmine::Plugin.register :redmine_webhook do
  name 'Redmine Webhook plugin'
  author 'Luiz Jr'
  description 'A Redmine plugin posts webhook on creating and updating tickets'
  version '0.1.0'
  url 'https://github.com/luizjr/redmine_webhook'
  author_url 'https://luizjr.dev'
  requires_redmine version_or_higher: '6.0.0'
  project_module :webhooks do
    permission :manage_hook, {:webhook_settings => [:index, :show, :update, :create, :destroy]}, :require => :member
  end
end

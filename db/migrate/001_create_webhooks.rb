class CreateWebhooks < ActiveRecord::Migration[4.2]
  # Instalação nova cria direto a tabela com o nome do plugin. Instalações
  # antigas já registraram esta migração (a tabela era "webhooks") e são
  # tratadas pela 002.
  def change
    create_table :redmine_webhooks do |t|
      t.string :url
      t.text :headers
      t.integer :project_id
    end
  end
end

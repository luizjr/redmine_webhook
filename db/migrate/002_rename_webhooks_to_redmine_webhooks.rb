# Leva a tabela antiga do plugin ("webhooks") para "redmine_webhooks".
#
# No upgrade para o Redmine 7 isso precisa acontecer ANTES do db:migrate do
# núcleo, que cria a própria "webhooks" e falha se ela já existir. O roteiro de
# upgrade faz o rename por SQL antes; esta migração cobre quem atualizou o
# plugin primeiro (ainda no 5.x/6.x) e é inofensiva quando o rename já foi feito.
class RenameWebhooksToRedmineWebhooks < ActiveRecord::Migration[4.2]
  def up
    return if table_exists?(:redmine_webhooks)
    return unless table_exists?(:webhooks) && column_exists?(:webhooks, :headers)

    rename_table :webhooks, :redmine_webhooks
  end

  def down
    # Sem volta automática: no Redmine 7 o nome "webhooks" é do núcleo.
  end
end

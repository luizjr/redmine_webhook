class CreateWebhooks < ActiveRecord::Migration[4.2]
  def change
    create_table :webhooks do |t|
      t.string :url
      t.text :headers
      t.integer :project_id
    end
  end
end

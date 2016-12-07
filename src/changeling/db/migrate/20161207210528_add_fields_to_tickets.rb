class AddFieldsToTickets < ActiveRecord::Migration[5.0]
  def up
    change_column :tickets, :external_id, :string, null: false
    change_column :tickets, :tracker, :string, null: false
    change_column :tickets, :status, :string, null: false
    add_column :tickets, :url, :text, default: "", null: false
    add_column :tickets, :open, :boolean, default: false, null: false
  end

  def down
    change_column :tickets, :external_id, :text, null: false
    change_column :tickets, :tracker, :text, null: false
    change_column :tickets, :status, :text, null: false
    remove_column :tickets, :url
    remove_column :tickets, :open
  end
end

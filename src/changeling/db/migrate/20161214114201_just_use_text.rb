class JustUseText < ActiveRecord::Migration[5.0]
  def up
    change_column :tickets, :external_id, :text, null: false
    change_column :tickets, :tracker, :text, null: false
    change_column :tickets, :status, :text, null: false
  end

  def down
    change_column :tickets, :external_id, :string, null: false
    change_column :tickets, :tracker, :string, null: false
    change_column :tickets, :status, :string, null: false
  end
end

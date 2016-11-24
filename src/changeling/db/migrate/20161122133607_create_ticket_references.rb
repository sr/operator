class CreateTicketReferences < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE TYPE ticket_management_software_name AS ENUM ('jira', 'gus')
    SQL

    create_table :tickets, id: :uuid do |t|
      t.text :external_id, null: false
      t.text :summary, null: false
      t.column :management_software, :ticket_management_software_name, null: false
      t.timestamps null: false
    end

    add_index :tickets, [:external_id, :management_software], :unique => true

    create_table :ticket_references, id: :uuid do |t|
      t.uuid :multipass_id, null: false
      t.uuid :ticket_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :ticket_references, :multipasses, primary_key: "uuid"
    add_foreign_key :ticket_references, :tickets

    add_index :ticket_references, [:multipass_id, :ticket_id], :unique => true
  end

  def down
    drop_table :tickets
    drop_table :ticket_references
    execute "DROP TYPE ticket_management_software_name"
  end
end

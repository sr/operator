class CreateTicketReferences < ActiveRecord::Migration[5.0]
  def up
    create_table :tickets, id: :uuid do |t|
      t.text :external_id, null: false
      t.text :summary, null: false
      t.text :tracker, null: false
      t.timestamps null: false
    end

    execute "ALTER TABLE tickets ADD CONSTRAINT tracker_check CHECK (tracker IN ('jira', 'gus'));"

    add_index :tickets, [:external_id, :tracker], :unique => true

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
    drop_table :ticket_references
    drop_table :tickets
  end
end

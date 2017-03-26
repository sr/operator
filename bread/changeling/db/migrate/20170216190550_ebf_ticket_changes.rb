class EbfTicketChanges < ActiveRecord::Migration[5.0]
  def change
    remove_index :ticket_references, name: "index_ticket_references_on_multipass_id_and_ticket_id"
    add_column :ticket_references, :ticket_type, :text, null: false, default: "story"
    execute "UPDATE ticket_references SET ticket_type = 'story'"
    execute "ALTER TABLE ticket_references ADD CONSTRAINT ticket_type CHECK (ticket_type IN ('story', 'emergency'));"
    add_index :ticket_references, [:multipass_id, :ticket_type], unique: true, where: "ticket_type = 'story'", name: "ticket_references_story_idx"
    add_index :ticket_references, [:multipass_id, :ticket_type], unique: true, where: "ticket_type = 'emergency'", name: "ticket_references_emergency_idx"
  end
end

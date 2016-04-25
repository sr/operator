class CreateServerTaggings < ActiveRecord::Migration
  def change
    create_table :server_taggings do |t|
      t.integer :server_id, null: false
      t.integer :server_tag_id, null: false
      t.timestamps null: false
    end

    add_index :server_taggings, [:server_id, :server_tag_id], unique: true
    add_index :server_taggings, :server_tag_id
  end
end

class CreateServerTags < ActiveRecord::Migration
  def change
    create_table :server_tags do |t|
      t.string :name, null: false
      t.timestamps null: false
    end

    add_index :server_tags, :name, unique: true
  end
end

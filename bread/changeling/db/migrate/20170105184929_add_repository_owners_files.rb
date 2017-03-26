class AddRepositoryOwnersFiles < ActiveRecord::Migration[5.0]
  def up
    create_table :repository_owners_files, id: :uuid do |t|
      t.text :repository_name, null: false
      t.text :path_name, null: false
      t.text :content, null: false
      t.timestamps null: false
    end

    add_index :repository_owners_files, [:repository_name, :path_name], unique: true
  end

  def down
    drop_table :repository_owners_files
  end
end

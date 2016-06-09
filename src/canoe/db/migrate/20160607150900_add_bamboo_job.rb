class AddBambooJob < ActiveRecord::Migration
  def up
    add_column :projects, :bamboo_job, :string, null: true
  end

  def down
    drop_column :projects, :bamboo_job
  end
end

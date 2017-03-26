class AddBuildNumberToDeploys < ActiveRecord::Migration
  def change
    add_column :deploys, :build_number, :integer, null: true
  end
end

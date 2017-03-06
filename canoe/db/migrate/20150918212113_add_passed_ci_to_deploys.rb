class AddPassedCiToDeploys < ActiveRecord::Migration
  def change
    # We'll assume that all passed deploys passed CI. It's true in most cases
    # and better than maintaining a nullable field.
    add_column :deploys, :passed_ci, :boolean, null: false, default: true
  end
end

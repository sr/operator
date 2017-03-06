class AddOptionsToDeploys < ActiveRecord::Migration
  def change
    add_column :deploys, :options_validator, :text, null: true
    add_column :deploys, :options, :text, null: true
  end
end

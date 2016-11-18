class AddTeamToMultipasses < ActiveRecord::Migration
  def change
    add_column :multipasses, :team, :string
  end
end

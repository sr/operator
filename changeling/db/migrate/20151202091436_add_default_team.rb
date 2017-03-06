class AddDefaultTeam < ActiveRecord::Migration
  def change
    change_column :multipasses, :team, :string, :default => "Unknown"
    execute("UPDATE multipasses SET team = 'Unknown' WHERE team IS NULL")
  end
end

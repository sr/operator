class AddDeployProcessId < ActiveRecord::Migration
  def change
    change_table :deploys do |t|
      t.string :process_id
    end
  end
end

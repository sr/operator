class AddCancelFlagToDeploy < ActiveRecord::Migration
  def change
    change_table :deploys do |t|
      t.boolean  :canceled, default: false
    end
  end
end

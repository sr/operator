class AddShaToDeploy < ActiveRecord::Migration
  def change
    change_table :deploys do |t|
      t.text :sha
    end
  end
end

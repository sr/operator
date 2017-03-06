class AddTimestampsToServers < ActiveRecord::Migration
  def change
    change_table :servers do |t|
      t.timestamps null: false, default: "2016-01-21 14:59:58"
    end
  end
end

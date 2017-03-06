class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :github_uid
      t.text :github_login

      t.timestamps null: false
    end
  end
end

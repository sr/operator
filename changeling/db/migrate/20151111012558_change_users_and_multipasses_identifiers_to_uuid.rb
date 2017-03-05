class ChangeUsersAndMultipassesIdentifiersToUuid < ActiveRecord::Migration
  def change
    add_column :multipasses, :uuid, :uuid, default: 'uuid_generate_v4()', primary: true
    add_column :users, :uuid, :uuid, default: 'uuid_generate_v4()', primary: true
    remove_column :users, :id, :integer
    remove_column :multipasses, :id, :integer
    execute 'ALTER TABLE users ADD PRIMARY KEY (uuid)'
    execute 'ALTER TABLE multipasses ADD PRIMARY KEY (uuid)'
  end
end

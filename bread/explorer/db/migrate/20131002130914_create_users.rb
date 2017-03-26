class CreateUsers < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE TABLE users (
        id int(11) NOT NULL AUTO_INCREMENT,
        email varchar(255) NOT NULL,
        name text NOT NULL,
        uid varchar(255) NOT NULL,
        created_at datetime NOT NULL,
        updated_at datetime NOT NULL,
        PRIMARY KEY (id),
        UNIQUE KEY (uid),
        UNIQUE KEY (email)
      )
    SQL
  end

  def down
    execute "DROP TABLE users"
  end
end

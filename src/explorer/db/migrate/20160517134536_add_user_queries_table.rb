class AddUserQueriesTable < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE TABLE user_queries (
        id int(11) NOT NULL AUTO_INCREMENT,
        account_id int(11) NULL,
        raw_sql text NOT NULL,
        user_id int(11) NOT NULL,
        created_at datetime NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      );
    SQL
  end

  def down
    execute "DROP TABLE user_queries"
  end
end

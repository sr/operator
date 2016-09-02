class ShowAllRows < ActiveRecord::Migration[5.0]
  def change
    add_column :user_queries, :all_rows, :boolean, default: false, null: false
  end
end

class AddDefaultToMultipassesBody < ActiveRecord::Migration[5.0]
  def up
    change_column :multipasses, :body, :text, null: false, default: ""
  end

  def down
    change_column :multipasses, :body, :text, null: false
  end
end

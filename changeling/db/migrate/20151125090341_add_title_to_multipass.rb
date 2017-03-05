class AddTitleToMultipass < ActiveRecord::Migration
  def change
    add_column :multipasses, :title, :string
  end
end

class AddRejectorToMultipass < ActiveRecord::Migration
  def change
    add_column :multipasses, :rejector, :string
  end
end

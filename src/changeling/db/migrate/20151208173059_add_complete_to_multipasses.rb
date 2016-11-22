class AddCompleteToMultipasses < ActiveRecord::Migration
  def change
    add_column :multipasses, :complete, :boolean, default: false
  end
end

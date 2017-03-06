class RemoveWhatColumn < ActiveRecord::Migration[5.0]
  def change
    remove_column :deploys, :what, :string
  end
end

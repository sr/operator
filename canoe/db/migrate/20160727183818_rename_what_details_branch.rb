class RenameWhatDetailsBranch < ActiveRecord::Migration[5.0]
  def change
    rename_column :deploys, :what_details, :branch
  end
end

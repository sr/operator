class AddReleaseIdToMultipass < ActiveRecord::Migration
  def change
    add_column :multipasses, :release_id, :string
  end
end

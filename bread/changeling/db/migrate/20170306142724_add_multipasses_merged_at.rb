class AddMultipassesMergedAt < ActiveRecord::Migration[5.0]
  def change
    add_column :multipasses, :merged_at, :datetime
  end
end

class AddIndexOnMultipassesReferenceUrl < ActiveRecord::Migration[5.0]
  def change
    add_index "multipasses", "reference_url", unique: true
  end
end

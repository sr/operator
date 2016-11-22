class AddIndexOnMultipasses < ActiveRecord::Migration
  def change
    add_index :multipasses, :team
    add_index :multipasses, :complete
    add_index :multipasses, :release_id, order: "text_pattern_ops"
  end
end

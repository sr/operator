class AddBodyToMultipasses < ActiveRecord::Migration[5.0]
  def up
    add_column :multipasses, :body, :text

    # Body will be updated to the actual value on the next sync
    Multipass.reset_column_information
    Multipass.update_all(body: "")

    change_column :multipasses, :body, :text, null: false
  end

  def down
    remove_column :multipasses, :body
  end
end

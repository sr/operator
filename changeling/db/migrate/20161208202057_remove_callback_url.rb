class RemoveCallbackUrl < ActiveRecord::Migration[5.0]
  def change
    remove_column :multipasses, :callback_url
  end
end

class AddCallbackUrlToMultipass < ActiveRecord::Migration
  def change
    add_column :multipasses, :callback_url, :string
  end
end

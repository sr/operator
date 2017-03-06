class AddRepositoryConfigFile < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :config_file_content, :text, null: true
  end
end

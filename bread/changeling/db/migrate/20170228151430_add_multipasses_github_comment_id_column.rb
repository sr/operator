class AddMultipassesGithubCommentIdColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :multipasses, :github_comment_id, :integer, default: nil, null: true
    add_index :multipasses, :github_comment_id, unique: true
  end
end

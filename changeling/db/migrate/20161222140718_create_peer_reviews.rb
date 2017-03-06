class CreatePeerReviews < ActiveRecord::Migration[5.0]
  def up
    create_table :peer_reviews, id: :uuid do |t|
      t.uuid :multipass_id, null: false
      t.text :reviewer_github_login, null: false
      t.text :state, null: false
      t.timestamps null: false
    end

    add_foreign_key :peer_reviews, :multipasses, primary_key: "uuid"
    add_index :peer_reviews, [:multipass_id, :reviewer_github_login], unique: true

    execute "ALTER TABLE peer_reviews ADD CONSTRAINT state CHECK (state IN ('APPROVED', 'CHANGES_REQUESTED'));"
  end

  def down
    drop_table :peer_reviews
  end
end

class AddSalesforceAuthenticatorPairing < ActiveRecord::Migration[5.0]
  def change
    create_table :salesforce_authenticator_pairings do |t|
      t.integer :auth_user_id, null: false
      t.string :pairing_id, null: false
      t.timestamps
    end

    add_foreign_key :salesforce_authenticator_pairings, :auth_users
    add_index :salesforce_authenticator_pairings, :pairing_id, unique: true
    add_index :salesforce_authenticator_pairings, :auth_user_id, unique: true
  end
end

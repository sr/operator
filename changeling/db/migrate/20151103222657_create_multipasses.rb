class CreateMultipasses < ActiveRecord::Migration
  def change
    create_table :multipasses do |t|
      t.string :reference_url
      t.string :requester
      t.string :impact
      t.string :impact_probability
      t.string :change_type
      t.string :peer_reviewer
      t.string :approver
      t.string :sre_approver
      t.boolean :testing
      t.text :backout_plan

      t.timestamps null: false
    end
  end
end

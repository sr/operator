class AddComplianceStateToDeploys < ActiveRecord::Migration[5.0]
  def change
    add_column :deploys, :compliance_state, :string, null: false, default: "pending"
  end
end

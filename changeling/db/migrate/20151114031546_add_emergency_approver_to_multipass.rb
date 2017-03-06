class AddEmergencyApproverToMultipass < ActiveRecord::Migration
  def change
    add_column :multipasses, :emergency_approver, :string
  end
end

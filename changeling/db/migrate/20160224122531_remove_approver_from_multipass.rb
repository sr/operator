class RemoveApproverFromMultipass < ActiveRecord::Migration
  def change
    remove_column :multipasses, :approver, :string
  end
end

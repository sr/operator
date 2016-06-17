class AddLockableStateToDeployTarget < ActiveRecord::Migration
  def change
    change_table :deploy_targets do |t|
      t.boolean  :lockable, default: false
    end
  end
end

class AddAffectsDefaultBranchToMultipasses < ActiveRecord::Migration[5.0]
  def change
    add_column :multipasses, :affects_default_branch, :bool, default: true, null: false
  end
end

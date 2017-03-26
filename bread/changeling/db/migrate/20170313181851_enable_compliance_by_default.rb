class EnableComplianceByDefault < ActiveRecord::Migration[5.0]
  def change
    execute "UPDATE repositories SET compliance_enabled = true WHERE name != 'kb-articles'"
    change_column_default(:repositories, :compliance_enabled, true)
  end
end

class AddressMultipassesDataIntegrityIssues < ActiveRecord::Migration[5.0]
  def change
    change_column_null :multipasses, :change_type, false
    change_column_null :multipasses, :complete, false
    change_column_null :multipasses, :impact, false
    change_column_null :multipasses, :impact_probability, false
    change_column_null :multipasses, :team, false
    change_column_null :multipasses, :title, false
    change_column_null :multipasses, :merged, false
    change_column_null :multipasses, :reference_url, false
    change_column_null :multipasses, :release_id, false
    change_column_null :multipasses, :requester, false
  end
end

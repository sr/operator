class ValidateChangeCategorization < ActiveRecord::Migration[5.0]
  def change
    execute "UPDATE multipasses SET change_type = 'standard'"
    execute "ALTER TABLE multipasses ADD CONSTRAINT change_type_check CHECK (change_type IN ('standard', 'major', 'emergency'))"
    execute "ALTER TABLE multipasses ADD CONSTRAINT impact_probability_check CHECK (impact_probability IN ('low', 'medium', 'high'))"
  end
end

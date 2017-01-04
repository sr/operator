class RenamePassedCiToTestsState < ActiveRecord::Migration[5.0]
  def up
    add_column :deploys, :compliance_state, :string, null: false, default: "pending"
    add_column :deploys, :tests_state, :string, null: false, default: "pending"

    Deploy.reset_column_information
    Deploy.find_each do |deploy|
      deploy.update!(tests_state: (deploy.passed_ci? ? "success" : "failure"))
    end

    remove_column :deploys, :passed_ci
  end

  def down
    add_column :deploys, :passed_ci, :boolean, default: true, null: false

    Deploy.reset_column_information
    Deploy.find_each do |deploy|
      deploy.update!(passed_ci: (deploy.tests_state == "success"))
    end

    remove_column :deploys, :compliance_state
    remove_column :deploys, :tests_state
  end
end

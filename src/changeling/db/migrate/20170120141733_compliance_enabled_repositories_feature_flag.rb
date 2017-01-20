class ComplianceEnabledRepositoriesFeatureFlag < ActiveRecord::Migration[5.0]
  ANSIBLE = "Pardot/ansible".freeze
  BLUE_MESH = "Pardot/blue-mesh".freeze
  BREAD = "Pardot/bread".freeze
  CHEF = "Pardot/chef".freeze
  INTERNAL_API = "Pardot/internal-api".freeze
  MESH = "Pardot/mesh".freeze
  MURDOC = "Pardot/murdoc".freeze
  PARDOT = "Pardot/pardot".freeze
  COMPLIANT_REPOSITORIES = [ANSIBLE, BLUE_MESH, BREAD, CHEF, INTERNAL_API, MESH, MURDOC, PARDOT].freeze

  def change
    add_column :repositories, :compliance_enabled, :boolean, null: false, default: false

    query = "UPDATE repositories SET compliance_enabled = true WHERE owner = %s AND name = %s"

    COMPLIANT_REPOSITORIES.each do |full_name|
      owner = full_name.split("/")[0]
      name = full_name.split("/")[1]

      execute format(
        query,
        ActiveRecord::Base.connection.quote(owner),
        ActiveRecord::Base.connection.quote(name)
      )
    end
  end
end

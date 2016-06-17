# Font awesome icons - http://fontawesome.io/3.2.1/icons/

namespace :canoe do
  desc "Create projects for deployment"
  task create_projects: :environment do
    next if Rails.env.test?

    Project.find_or_initialize_by(name: "explorer").tap do |project|
      project.icon = "search"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "BREAD"
      project.bamboo_job = "EX"
      project.repository = "Pardot/bread"
    end.save!

    Project.find_or_initialize_by(name: "pardot").tap do |project|
      project.icon = "cloud"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "PPANT"
      project.repository = "Pardot/pardot"
    end.save!

    Project.find_or_initialize_by(name: "pithumbs").tap do |project|
      project.icon = "thumbs-up"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "PTHMBS"
      project.repository = "Pardot/pithumbs"
    end.save!

    Project.find_or_initialize_by(name: "realtime-frontend").tap do |project|
      project.icon = "bullhorn"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "RTF"
      project.repository = "Pardot/realtime-frontend"
    end.save!

    Project.find_or_initialize_by(name: "workflow-stats").tap do |project|
      project.icon = "fighter-jet"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "WFST"
      project.repository = "Pardot/workflow-stats"
    end.save!

    Project.find_or_initialize_by(name: "murdoc").tap do |project|
      project.icon = "bolt"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "MDOC"
      project.repository = "Pardot/murdoc"
    end.save!

    Project.find_or_initialize_by(name: "chef").tap do |project|
      project.icon = "food"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "CHEF"
      project.repository = "Pardot/chef"
    end.save!

    Project.find_or_initialize_by(name: "repfix").tap do |project|
      project.icon = "wrench"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "REPFIX"
      project.repository = "Pardot/repfix"
    end.save!

    Project.find_or_initialize_by(name: "internal-api").tap do |project|
      project.icon = "building"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "INTAPI"
      project.repository = "Pardot/internal-api"
    end.save!

    Project.find_or_initialize_by(name: "blue-mesh").tap do |project|
      project.icon = "th"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "BLUMSH"
      project.repository = "Pardot/blue-mesh"
    end.save!

    Project.find_or_initialize_by(name: "mesh").tap do |project|
      project.icon = "th-large"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "MESH"
      project.repository = "Pardot/mesh"
    end.save!

    Project.find_or_initialize_by(name: "ansible").tap do |project|
      project.icon = "signal"
      project.bamboo_project = "SRE"
      project.bamboo_plan = "ANSBL"
      project.repository = "Pardot/ansible"
    end.save!
  end

  desc "Create targets for deployment"
  task create_targets: :environment do
    next if Rails.env.test?

    case Rails.env
    when "development"
      DeployTarget.find_or_initialize_by(name: "test").save!
      DeployScenario.find_or_create_by(
        project: Project.find_or_create_by(name: "pardot"),
        server: Server.find_or_create_by(hostname: "local-1"),
        deploy_target: DeployTarget.find_or_create_by(name: "dev")
      )
    when "production"
      DeployTarget.find_or_initialize_by(name: "staging").save!
      DeployTarget.find_or_initialize_by(name: "production").tap do |target|
        target.production = true
      end.save!
      DeployTarget.find_or_initialize_by(name: "production_dfw").tap do |target|
        target.production = true
        target.enabled = false
      end.save!
      DeployTarget.find_or_initialize_by(name: "production_phx").tap do |target|
        target.production = true
        target.enabled = false
      end.save!
    end
  end

  desc "Create deploy ACLs"
  task create_deploy_acls: :environment do
    next if Rails.env.test?

    case Rails.env
    when "production"
      # Until we coordinate with the Security team to make more granular groups,
      # require 'releasebox' for all production deployments in all projects
      production_targets = DeployTarget.where(name: %w[production production_dfw production_phx])
      Project.find_each do |project|
        production_targets.each do |target|
          DeployACLEntry.find_or_initialize_by(project_id: project.id, deploy_target_id: target.id).tap do |entry|
            entry.acl_type = "ldap_group"
            entry.value = ["releasebox"]
          end.save!
        end
      end
    end
  end
end

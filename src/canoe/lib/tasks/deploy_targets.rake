# Font awesome icons - http://fontawesome.io/3.2.1/icons/

namespace :canoe do
  desc "Create projects for deployment"
  task create_projects: :environment do
    next if Rails.env.test?

    bread = Project.find_or_initialize_by(name: "explorer").tap { |project|
      project.icon = "search"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "BREAD"
      project.bamboo_job = "EX"
      project.repository = "Pardot/bread"
      project.save!
    }.tap(&:save!)
    bread.deploy_notifications.find_or_initialize_by(hipchat_room_id: 42).tap(&:save!) # BREAD

    pardot = Project.find_or_initialize_by(name: "pardot").tap { |project|
      project.icon = "cloud"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "PPANT"
      project.repository = "Pardot/pardot"
    }.tap(&:save!)
    pardot.deploy_notifications.find_or_initialize_by(hipchat_room_id: 2).tap(&:save!) # Engineering
    pardot.deploy_notifications.find_or_initialize_by(hipchat_room_id: 28).tap(&:save!) # Support

    pithumbs = Project.find_or_initialize_by(name: "pithumbs").tap { |project|
      project.icon = "thumbs-up"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "PTHMBS"
      project.repository = "Pardot/pithumbs"
    }.tap(&:save!)
    pithumbs.deploy_notifications.find_or_initialize_by(hipchat_room_id: 2).tap(&:save!) # Engineering
    pithumbs.deploy_notifications.find_or_initialize_by(hipchat_room_id: 28).tap(&:save!) # Support

    rtf = Project.find_or_initialize_by(name: "realtime-frontend").tap { |project|
      project.icon = "bullhorn"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "RTF"
      project.repository = "Pardot/realtime-frontend"
    }.tap(&:save!)
    rtf.deploy_notifications.find_or_initialize_by(hipchat_room_id: 2).tap(&:save!) # Engineering
    rtf.deploy_notifications.find_or_initialize_by(hipchat_room_id: 28).tap(&:save!) # Support

    wfst = Project.find_or_initialize_by(name: "workflow-stats").tap { |project|
      project.icon = "fighter-jet"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "WFST"
      project.repository = "Pardot/workflow-stats"
    }.tap(&:save!)
    wfst.deploy_notifications.find_or_initialize_by(hipchat_room_id: 901).tap(&:save!) # ES Oncall

    murdoc = Project.find_or_initialize_by(name: "murdoc").tap { |project|
      project.icon = "bolt"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "MDOC"
      project.repository = "Pardot/murdoc"
      project.all_servers_default = false
    }.tap(&:save!)
    murdoc.deploy_notifications.find_or_initialize_by(hipchat_room_id: 901).tap(&:save!) # ES Oncall

    chef = Project.find_or_initialize_by(name: "chef").tap { |project|
      project.icon = "food"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "CHEF"
      project.repository = "Pardot/chef"
    }.tap(&:save!)

    repfix = Project.find_or_initialize_by(name: "repfix").tap { |project|
      project.icon = "wrench"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "REPFIX"
      project.repository = "Pardot/repfix"
    }.tap(&:save!)
    repfix.deploy_notifications.find_or_initialize_by(hipchat_room_id: 42).tap(&:save!) # BREAD

    intapi = Project.find_or_initialize_by(name: "internal-api").tap { |project|
      project.icon = "building"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "INTAPI"
      project.repository = "Pardot/internal-api"
    }.tap(&:save!)
    intapi.deploy_notifications.find_or_initialize_by(hipchat_room_id: 42).tap(&:save!) # BREAD

    blue_mesh = Project.find_or_initialize_by(name: "blue-mesh").tap { |project|
      project.icon = "th"
      project.bamboo_project = "PDT"
      project.bamboo_plan = "BLUMSH"
      project.repository = "Pardot/blue-mesh"
    }.tap(&:save!)
    blue_mesh.deploy_notifications.find_or_initialize_by(hipchat_room_id: 437).tap(&:save!) # Team Caerus

    mesh = Project.find_or_initialize_by(name: "mesh").tap { |project|
      project.icon = "th-large"
      project.bamboo_project = "BREAD"
      project.bamboo_plan = "MESH"
      project.repository = "Pardot/mesh"
    }.tap(&:save!)
    mesh.deploy_notifications.find_or_initialize_by(hipchat_room_id: 437).tap(&:save!) # Team Caerus

    ansible = Project.find_or_initialize_by(name: "ansible").tap { |project|
      project.icon = "signal"
      project.bamboo_project = "SRE"
      project.bamboo_plan = "ANSBL"
      project.repository = "Pardot/ansible"
    }.tap(&:save!)
    ansible.deploy_notifications.find_or_initialize_by(hipchat_room_id: 6).tap(&:save!) # Ops
  end

  desc "Create targets for deployment"
  task create_targets: :environment do
    next if Rails.env.test?

    case Rails.env
    when "development"
      DeployTarget.find_or_initialize_by(name: "test").tap(&:save!)
      DeployScenario.find_or_create_by(
        project: Project.find_or_create_by(name: "pardot"),
        server: Server.find_or_create_by(hostname: "local-1"),
        deploy_target: DeployTarget.find_or_create_by(name: "dev")
      )
    when "production"
      DeployTarget.find_or_initialize_by(name: "staging").tap(&:save!)
      DeployTarget.find_or_initialize_by(name: "production").tap { |target|
        target.production = true
      }.tap(&:save!)
      DeployTarget.find_or_initialize_by(name: "production_dfw").tap { |target|
        target.production = true
        target.enabled = false
      }.tap(&:save!)
      DeployTarget.find_or_initialize_by(name: "production_phx").tap { |target|
        target.production = true
        target.enabled = false
      }.tap(&:save!)
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
          DeployACLEntry.find_or_initialize_by(project_id: project.id, deploy_target_id: target.id).tap { |entry|
            entry.acl_type = "ldap_group"
            entry.value = ["releasebox"]
          }.tap(&:save!)
        end
      end
    end
  end
end

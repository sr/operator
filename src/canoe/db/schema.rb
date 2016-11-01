# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161031203534) do

  create_table "auth_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email"
    t.string   "name"
    t.string   "uid",        null: false
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uid"], name: "index_auth_users_on_uid", unique: true, using: :btree
  end

  create_table "chef_deploys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "branch",                         null: false
    t.string   "build_url",                      null: false
    t.string   "environment",                    null: false
    t.string   "sha",                            null: false
    t.string   "state",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "datacenter",       limit: 65535, null: false
    t.text     "hostname",         limit: 65535, null: false
    t.datetime "last_notified_at"
  end

  create_table "deploy_acl_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id",                     null: false
    t.integer  "deploy_target_id",               null: false
    t.string   "acl_type",                       null: false
    t.text     "value",            limit: 65535, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["deploy_target_id", "project_id"], name: "index_deploy_acl_entries_on_deploy_target_id_and_project_id", unique: true, using: :btree
    t.index ["project_id"], name: "index_deploy_acl_entries_on_project_id", using: :btree
  end

  create_table "deploy_notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id",      null: false
    t.integer  "hipchat_room_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["project_id", "hipchat_room_id"], name: "index_deploy_notifications_on_project_id_and_hipchat_room_id", unique: true, using: :btree
  end

  create_table "deploy_restart_servers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "deploy_id",  null: false
    t.integer  "server_id"
    t.string   "datacenter", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deploy_id"], name: "index_deploy_restart_servers_on_deploy_id", using: :btree
  end

  create_table "deploy_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "server_id",                                 null: false
    t.integer "deploy_id",                                 null: false
    t.string  "stage",                   default: "start", null: false
    t.text    "logs",      limit: 65535
    t.index ["deploy_id", "stage"], name: "index_deploy_results_on_deploy_id_and_stage", using: :btree
    t.index ["server_id", "deploy_id"], name: "index_deploy_results_on_server_id_and_deploy_id", unique: true, using: :btree
  end

  create_table "deploy_scenarios", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "project_id",       null: false
    t.integer "server_id",        null: false
    t.integer "deploy_target_id", null: false
    t.index ["project_id", "deploy_target_id", "server_id"], name: "index_deploy_scenarios_on_repo_deploy_server_ids", unique: true, using: :btree
  end

  create_table "deploy_targets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "locking_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",         default: true,  null: false
    t.boolean  "production",      default: false, null: false
    t.index ["enabled"], name: "index_deploy_targets_on_enabled", using: :btree
    t.index ["name"], name: "index_deploy_targets_on_name", using: :btree
  end

  create_table "deploys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "deploy_target_id"
    t.integer  "auth_user_id"
    t.string   "project_name"
    t.string   "branch"
    t.boolean  "completed",                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "canceled",                        default: false
    t.text     "servers_used",      limit: 65535
    t.text     "specified_servers", limit: 65535
    t.text     "completed_servers", limit: 65535
    t.text     "sha",               limit: 65535
    t.integer  "build_number"
    t.string   "artifact_url"
    t.boolean  "passed_ci",                       default: true,  null: false
    t.text     "options_validator", limit: 65535
    t.text     "options",           limit: 65535
    t.index ["deploy_target_id"], name: "index_deploys_on_deploy_target_id", using: :btree
  end

  create_table "locks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "deploy_target_id", null: false
    t.integer  "auth_user_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",       null: false
    t.index ["deploy_target_id", "project_id"], name: "index_locks_on_deploy_target_id_and_project_id", unique: true, using: :btree
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",                                                                                  null: false
    t.string  "icon",                                                                                  null: false
    t.string  "bamboo_project"
    t.string  "bamboo_plan"
    t.string  "repository",                                                                            null: false
    t.string  "bamboo_job"
    t.boolean "all_servers_default",                                                   default: true,  null: false
    t.decimal "maximum_unavailable_percentage_per_datacenter", precision: 5, scale: 2, default: "1.0", null: false
    t.index ["name"], name: "index_projects_on_name", unique: true, using: :btree
  end

  create_table "salesforce_authenticator_pairings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "auth_user_id", null: false
    t.string   "pairing_id",   null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["auth_user_id"], name: "index_salesforce_authenticator_pairings_on_auth_user_id", unique: true, using: :btree
    t.index ["pairing_id"], name: "index_salesforce_authenticator_pairings_on_pairing_id", unique: true, using: :btree
  end

  create_table "server_taggings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "server_id",     null: false
    t.integer  "server_tag_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["server_id", "server_tag_id"], name: "index_server_taggings_on_server_id_and_server_tag_id", unique: true, using: :btree
    t.index ["server_tag_id"], name: "index_server_taggings_on_server_tag_id", using: :btree
  end

  create_table "server_tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_server_tags_on_name", unique: true, using: :btree
  end

  create_table "servers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "hostname",                                   null: false
    t.boolean  "enabled",    default: true,                  null: false
    t.datetime "created_at", default: '2016-01-21 14:59:58', null: false
    t.datetime "updated_at", default: '2016-01-21 14:59:58', null: false
    t.boolean  "archived",   default: false,                 null: false
    t.index ["archived"], name: "index_servers_on_archived", using: :btree
    t.index ["hostname"], name: "index_servers_on_hostname", unique: true, using: :btree
  end

  create_table "target_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "deploy_target_id"
    t.integer  "auth_user_id"
    t.string   "job_name"
    t.string   "command"
    t.string   "process_id"
    t.boolean  "completed",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["auth_user_id"], name: "index_target_jobs_on_auth_user_id", using: :btree
    t.index ["deploy_target_id"], name: "index_target_jobs_on_deploy_target_id", using: :btree
  end

  create_table "terraform_deploys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "terraform_project_id",                 null: false
    t.integer  "auth_user_id",                         null: false
    t.string   "request_id",                           null: false
    t.string   "branch_name",                          null: false
    t.string   "commit_sha1",                          null: false
    t.string   "terraform_version",                    null: false
    t.boolean  "successful",           default: false, null: false
    t.datetime "completed_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["auth_user_id"], name: "fk_rails_1c5e040a85", using: :btree
    t.index ["request_id"], name: "index_terraform_deploys_on_request_id", unique: true, using: :btree
    t.index ["terraform_project_id"], name: "fk_rails_f0c94d960b", using: :btree
  end

  create_table "terraform_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id", null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_terraform_projects_on_name", unique: true, using: :btree
    t.index ["project_id"], name: "index_terraform_projects_on_project_id", unique: true, using: :btree
  end

  add_foreign_key "salesforce_authenticator_pairings", "auth_users"
  add_foreign_key "terraform_deploys", "auth_users"
  add_foreign_key "terraform_deploys", "terraform_projects"
  add_foreign_key "terraform_projects", "projects"
end

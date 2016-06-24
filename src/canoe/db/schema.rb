# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160622112051) do

  create_table "auth_users", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.string   "name",       limit: 255
    t.string   "uid",        limit: 255, null: false
    t.string   "token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_users", ["uid"], name: "index_auth_users_on_uid", unique: true, using: :btree

  create_table "chef_deploys", force: :cascade do |t|
    t.string   "branch",           limit: 255,   null: false
    t.string   "build_url",        limit: 255,   null: false
    t.string   "environment",      limit: 255,   null: false
    t.string   "sha",              limit: 255,   null: false
    t.string   "state",            limit: 255,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "datacenter",       limit: 65535, null: false
    t.text     "hostname",         limit: 65535, null: false
    t.datetime "last_notified_at"
  end

  create_table "deploy_acl_entries", force: :cascade do |t|
    t.integer  "project_id",       limit: 4,     null: false
    t.integer  "deploy_target_id", limit: 4,     null: false
    t.string   "acl_type",         limit: 255,   null: false
    t.text     "value",            limit: 65535, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "deploy_acl_entries", ["deploy_target_id", "project_id"], name: "index_deploy_acl_entries_on_deploy_target_id_and_project_id", unique: true, using: :btree
  add_index "deploy_acl_entries", ["project_id"], name: "index_deploy_acl_entries_on_project_id", using: :btree

  create_table "deploy_restart_servers", force: :cascade do |t|
    t.integer  "deploy_id",  limit: 4,   null: false
    t.integer  "server_id",  limit: 4
    t.string   "datacenter", limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "deploy_restart_servers", ["deploy_id"], name: "index_deploy_restart_servers_on_deploy_id", using: :btree

  create_table "deploy_results", force: :cascade do |t|
    t.integer "server_id", limit: 4,                           null: false
    t.integer "deploy_id", limit: 4,                           null: false
    t.string  "stage",     limit: 255,   default: "initiated", null: false
    t.text    "logs",      limit: 65535
  end

  add_index "deploy_results", ["deploy_id", "stage"], name: "index_deploy_results_on_deploy_id_and_stage", using: :btree
  add_index "deploy_results", ["server_id", "deploy_id"], name: "index_deploy_results_on_server_id_and_deploy_id", unique: true, using: :btree

  create_table "deploy_scenarios", force: :cascade do |t|
    t.integer "project_id",       limit: 4, null: false
    t.integer "server_id",        limit: 4, null: false
    t.integer "deploy_target_id", limit: 4, null: false
  end

  add_index "deploy_scenarios", ["project_id", "deploy_target_id", "server_id"], name: "index_deploy_scenarios_on_repo_deploy_server_ids", unique: true, using: :btree

  create_table "deploy_targets", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "locking_user_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",                     default: true,  null: false
    t.boolean  "production",                  default: false, null: false
  end

  add_index "deploy_targets", ["enabled"], name: "index_deploy_targets_on_enabled", using: :btree
  add_index "deploy_targets", ["name"], name: "index_deploy_targets_on_name", using: :btree

  create_table "deploys", force: :cascade do |t|
    t.integer  "deploy_target_id",  limit: 4
    t.integer  "auth_user_id",      limit: 4
    t.string   "project_name",      limit: 255
    t.string   "what",              limit: 255
    t.string   "what_details",      limit: 255
    t.boolean  "completed",                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "canceled",                        default: false
    t.text     "servers_used",      limit: 65535
    t.text     "specified_servers", limit: 65535
    t.text     "completed_servers", limit: 65535
    t.text     "sha",               limit: 65535
    t.integer  "build_number",      limit: 4
    t.string   "artifact_url",      limit: 255
    t.boolean  "passed_ci",                       default: true,  null: false
    t.text     "options_validator", limit: 65535
    t.text     "options",           limit: 65535
  end

  add_index "deploys", ["deploy_target_id"], name: "index_deploys_on_deploy_target_id", using: :btree

  create_table "locks", force: :cascade do |t|
    t.integer  "deploy_target_id", limit: 4, null: false
    t.integer  "auth_user_id",     limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",       limit: 4, null: false
  end

  add_index "locks", ["deploy_target_id", "project_id"], name: "index_locks_on_deploy_target_id_and_project_id", unique: true, using: :btree

  create_table "projects", force: :cascade do |t|
    t.string "name",           limit: 255, null: false
    t.string "icon",           limit: 255, null: false
    t.string "bamboo_project", limit: 255
    t.string "bamboo_plan",    limit: 255
    t.string "repository",     limit: 255, null: false
    t.string "bamboo_job",     limit: 255
  end

  add_index "projects", ["name"], name: "index_projects_on_name", unique: true, using: :btree

  create_table "server_taggings", force: :cascade do |t|
    t.integer  "server_id",     limit: 4, null: false
    t.integer  "server_tag_id", limit: 4, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "server_taggings", ["server_id", "server_tag_id"], name: "index_server_taggings_on_server_id_and_server_tag_id", unique: true, using: :btree
  add_index "server_taggings", ["server_tag_id"], name: "index_server_taggings_on_server_tag_id", using: :btree

  create_table "server_tags", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "server_tags", ["name"], name: "index_server_tags_on_name", unique: true, using: :btree

  create_table "servers", force: :cascade do |t|
    t.string   "hostname",   limit: 255,                                 null: false
    t.boolean  "enabled",                default: true,                  null: false
    t.datetime "created_at",             default: '2016-01-21 14:59:58', null: false
    t.datetime "updated_at",             default: '2016-01-21 14:59:58', null: false
  end

  add_index "servers", ["hostname"], name: "index_servers_on_hostname", unique: true, using: :btree

  create_table "target_jobs", force: :cascade do |t|
    t.integer  "deploy_target_id", limit: 4
    t.integer  "auth_user_id",     limit: 4
    t.string   "job_name",         limit: 255
    t.string   "command",          limit: 255
    t.string   "process_id",       limit: 255
    t.boolean  "completed",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "target_jobs", ["auth_user_id"], name: "index_target_jobs_on_auth_user_id", using: :btree
  add_index "target_jobs", ["deploy_target_id"], name: "index_target_jobs_on_deploy_target_id", using: :btree

end

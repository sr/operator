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

ActiveRecord::Schema.define(version: 20150922211320) do

  create_table "auth_users", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.string   "name",       limit: 255
    t.string   "uid",        limit: 255
    t.string   "token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_users", ["email"], name: "index_auth_users_on_email", using: :btree

  create_table "deploy_results", force: :cascade do |t|
    t.integer "server_id", limit: 4,                         null: false
    t.integer "deploy_id", limit: 4,                         null: false
    t.string  "status",    limit: 255,   default: "pending", null: false
    t.text    "logs",      limit: 65535
  end

  add_index "deploy_results", ["deploy_id", "status"], name: "index_deploy_results_on_deploy_id_and_status", using: :btree
  add_index "deploy_results", ["server_id", "deploy_id"], name: "index_deploy_results_on_server_id_and_deploy_id", unique: true, using: :btree

  create_table "deploy_scenarios", force: :cascade do |t|
    t.integer "repo_id",          limit: 4, null: false
    t.integer "server_id",        limit: 4, null: false
    t.integer "deploy_target_id", limit: 4, null: false
  end

  add_index "deploy_scenarios", ["repo_id", "deploy_target_id", "server_id"], name: "index_deploy_scenarios_on_repo_deploy_server_ids", unique: true, using: :btree

  create_table "deploy_targets", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "script_path",     limit: 255
    t.integer  "locking_user_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deploy_targets", ["name"], name: "index_deploy_targets_on_name", using: :btree

  create_table "deploys", force: :cascade do |t|
    t.integer  "deploy_target_id",  limit: 4
    t.integer  "auth_user_id",      limit: 4
    t.string   "repo_name",         limit: 255
    t.string   "what",              limit: 255
    t.string   "what_details",      limit: 255
    t.boolean  "completed",                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "process_id",        limit: 255
    t.boolean  "canceled",                        default: false
    t.text     "servers_used",      limit: 65535
    t.text     "specified_servers", limit: 65535
    t.text     "completed_servers", limit: 65535
    t.text     "sha",               limit: 65535
    t.integer  "build_number",      limit: 4
    t.string   "artifact_url",      limit: 255
    t.boolean  "passed_ci",                       default: true,  null: false
  end

  add_index "deploys", ["deploy_target_id"], name: "index_deploys_on_deploy_target_id", using: :btree

  create_table "locks", force: :cascade do |t|
    t.integer  "deploy_target_id", limit: 4, null: false
    t.integer  "auth_user_id",     limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repo_id",          limit: 4, null: false
  end

  add_index "locks", ["deploy_target_id", "repo_id"], name: "index_locks_on_deploy_target_id_and_repo_id", unique: true, using: :btree

  create_table "repos", force: :cascade do |t|
    t.string  "name",                   limit: 255,                 null: false
    t.string  "icon",                   limit: 255,                 null: false
    t.boolean "supports_branch_deploy",             default: false, null: false
    t.boolean "deploys_via_artifacts",              default: false, null: false
    t.string  "bamboo_project",         limit: 255
    t.string  "bamboo_plan",            limit: 255
  end

  add_index "repos", ["name"], name: "index_repos_on_name", unique: true, using: :btree

  create_table "servers", force: :cascade do |t|
    t.string  "hostname", limit: 255,                null: false
    t.boolean "enabled",              default: true, null: false
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

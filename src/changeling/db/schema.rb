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

ActiveRecord::Schema.define(version: 20170117143955) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "audits", primary_key: "uuid", force: :cascade do |t|
    t.uuid     "auditable_id"
    t.string   "auditable_type"
    t.uuid     "associated_id"
    t.string   "associated_type"
    t.uuid     "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "events", primary_key: "uuid", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "external_id"
    t.string   "app_name"
    t.string   "resource"
    t.string   "action"
    t.jsonb    "payload",      default: {}, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.uuid     "multipass_id"
    t.string   "release_sha"
    t.uuid     "user_id"
    t.index ["app_name"], name: "index_events_on_app_name", using: :btree
    t.index ["created_at"], name: "index_events_on_created_at", using: :btree
    t.index ["user_id"], name: "index_events_on_user_id", using: :btree
  end

  create_table "github_installations", force: :cascade do |t|
    t.text     "hostname",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hostname"], name: "index_github_installations_on_hostname", unique: true, using: :btree
  end

  create_table "multipasses", primary_key: "uuid", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "reference_url",                          null: false
    t.string   "requester",                              null: false
    t.string   "impact",                                 null: false
    t.string   "impact_probability",                     null: false
    t.string   "change_type",                            null: false
    t.string   "peer_reviewer"
    t.string   "sre_approver"
    t.boolean  "testing"
    t.text     "backout_plan"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "team",               default: "Unknown", null: false
    t.boolean  "merged",             default: false,     null: false
    t.string   "release_id",                             null: false
    t.string   "emergency_approver"
    t.string   "title",                                  null: false
    t.boolean  "complete",           default: false,     null: false
    t.string   "rejector"
    t.string   "tests_state",        default: "pending", null: false
    t.index "release_id text_pattern_ops", name: "index_multipasses_on_release_id", using: :btree
    t.index ["complete"], name: "index_multipasses_on_complete", using: :btree
    t.index ["team"], name: "index_multipasses_on_team", using: :btree
  end

  create_table "peer_reviews", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "multipass_id",          null: false
    t.text     "reviewer_github_login", null: false
    t.text     "state",                 null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["multipass_id", "reviewer_github_login"], name: "index_peer_reviews_on_multipass_id_and_reviewer_github_login", unique: true, using: :btree
  end

  create_table "pull_request_files", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "multipass_id", null: false
    t.text     "filename",     null: false
    t.text     "state",        null: false
    t.text     "patch",        null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["multipass_id", "filename"], name: "index_pull_request_files_on_multipass_id_and_filename", unique: true, using: :btree
  end

  create_table "repositories", force: :cascade do |t|
    t.integer  "github_installation_id", null: false
    t.integer  "github_id",              null: false
    t.integer  "github_owner_id",        null: false
    t.text     "owner",                  null: false
    t.text     "name",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "deleted_at"
    t.index ["github_installation_id", "github_owner_id", "github_id"], name: "repositories_github_ids_unique_idx", unique: true, using: :btree
    t.index ["github_installation_id", "owner", "name"], name: "repositories_github_names_unique_idx", unique: true, using: :btree
  end

  create_table "repository_commit_statuses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "sha",                  null: false
    t.string   "context",              null: false
    t.text     "state",                null: false
    t.integer  "github_repository_id", null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["github_repository_id", "sha", "context"], name: "repository_commit_statuses_unique_idx", unique: true, using: :btree
  end

  create_table "repository_owners_files", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text     "repository_name", null: false
    t.text     "path_name",       null: false
    t.text     "content",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["repository_name", "path_name"], name: "index_repository_owners_files_on_repository_name_and_path_name", unique: true, using: :btree
  end

  create_table "ticket_references", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "multipass_id", null: false
    t.uuid     "ticket_id",    null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["multipass_id", "ticket_id"], name: "index_ticket_references_on_multipass_id_and_ticket_id", unique: true, using: :btree
  end

  create_table "tickets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text     "external_id",                 null: false
    t.text     "summary",                     null: false
    t.text     "tracker",                     null: false
    t.text     "status",                      null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "url",         default: "",    null: false
    t.boolean  "open",        default: false, null: false
    t.index ["external_id", "tracker"], name: "index_tickets_on_external_id_and_tracker", unique: true, using: :btree
  end

  create_table "users", primary_key: "uuid", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text     "github_uid"
    t.text     "github_login"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.text     "encrypted_github_token"
    t.string   "team"
  end

  add_foreign_key "peer_reviews", "multipasses", primary_key: "uuid"
  add_foreign_key "repositories", "github_installations"
  add_foreign_key "ticket_references", "multipasses", primary_key: "uuid"
  add_foreign_key "ticket_references", "tickets"
end

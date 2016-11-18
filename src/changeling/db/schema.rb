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

ActiveRecord::Schema.define(version: 20160603084848) do

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

  create_table "multipasses", primary_key: "uuid", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "reference_url"
    t.string   "requester"
    t.string   "impact"
    t.string   "impact_probability"
    t.string   "change_type"
    t.string   "peer_reviewer"
    t.string   "sre_approver"
    t.boolean  "testing"
    t.text     "backout_plan"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "team",               default: "Unknown"
    t.boolean  "merged",             default: false
    t.string   "callback_url"
    t.string   "release_id"
    t.string   "emergency_approver"
    t.string   "title"
    t.boolean  "complete",           default: false
    t.string   "rejector"
    t.index "release_id text_pattern_ops", name: "index_multipasses_on_release_id", using: :btree
    t.index ["complete"], name: "index_multipasses_on_complete", using: :btree
    t.index ["team"], name: "index_multipasses_on_team", using: :btree
  end

  create_table "users", primary_key: "uuid", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text     "github_uid"
    t.text     "github_login"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.text     "encrypted_github_token"
    t.string   "team"
  end

end

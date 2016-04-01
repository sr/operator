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

ActiveRecord::Schema.define(version: 20140915151939) do

  create_table "auth_users", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.string   "name",       limit: 255
    t.string   "uid",        limit: 255
    t.string   "token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_users", ["email"], name: "index_auth_users_on_email", using: :btree

  create_table "queries", force: :cascade do |t|
    t.string   "database",   limit: 255
    t.string   "datacenter", limit: 255
    t.integer  "account_id", limit: 4
    t.text     "sql",        limit: 65535
    t.string   "view",       limit: 255
    t.boolean  "is_limited",               default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

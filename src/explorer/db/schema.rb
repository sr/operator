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

ActiveRecord::Schema.define(version: 20160517134536) do

  create_table "user_queries", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.text     "raw_sql",    limit: 65535, null: false
    t.integer  "user_id",    limit: 4,     null: false
    t.datetime "created_at",               null: false
  end

  add_index "user_queries", ["user_id"], name: "user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",      limit: 255,   null: false
    t.text     "name",       limit: 65535, null: false
    t.string   "uid",        limit: 255,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "users", ["email"], name: "email", unique: true, using: :btree
  add_index "users", ["uid"], name: "uid", unique: true, using: :btree

  add_foreign_key "user_queries", "users", name: "user_queries_ibfk_1"
end

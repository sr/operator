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

ActiveRecord::Schema.define(version: 20160611151703) do

  create_table "user_queries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "account_id"
    t.text     "raw_sql",    limit: 65535, null: false
    t.integer  "user_id",                  null: false
    t.datetime "created_at",               null: false
    t.index ["user_id"], name: "user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                                                   null: false
    t.text     "name",                          limit: 65535,             null: false
    t.string   "uid",                                                     null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "rate_limit_transactions_count",               default: 0, null: false
    t.datetime "rate_limit_expires_at"
    t.index ["email"], name: "email", unique: true, using: :btree
    t.index ["uid"], name: "uid", unique: true, using: :btree
  end

  add_foreign_key "user_queries", "users", name: "user_queries_ibfk_1"
end

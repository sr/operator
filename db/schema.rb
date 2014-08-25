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

ActiveRecord::Schema.define(version: 20140825172247) do

  create_table "api_key", force: true do |t|
    t.integer  "account_id",                   null: false
    t.integer  "user_id",                      null: false
    t.string   "application_name", limit: 100
    t.string   "api_key",          limit: 32,  null: false
    t.string   "ip_address",       limit: 32,  null: false
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "expires_at"
  end

  add_index "api_key", ["account_id"], name: "api_key_FI_1", using: :btree
  add_index "api_key", ["api_key"], name: "api_key", unique: true, using: :btree
  add_index "api_key", ["created_by"], name: "api_key_FI_3", using: :btree
  add_index "api_key", ["user_id"], name: "api_key_FI_2", using: :btree

  create_table "app_metric", force: true do |t|
    t.integer  "account_id"
    t.integer  "shard_id"
    t.string   "module",          limit: 64
    t.string   "action",          limit: 64
    t.string   "hostname",        limit: 128
    t.text     "referer"
    t.string   "request_uri"
    t.text     "request_params"
    t.text     "cookies"
    t.integer  "user_id"
    t.text     "user_details"
    t.text     "visitor_details"
    t.integer  "visitor_id"
    t.float    "execution_time",  limit: 24
    t.datetime "created_at"
  end

  create_table "db_migration", force: true do |t|
    t.integer  "type",                    null: false
    t.string   "file",                    null: false
    t.integer  "applied",     default: 0, null: false
    t.datetime "applied_at"
    t.integer  "is_approved", default: 0, null: false
    t.integer  "is_denied",   default: 0, null: false
    t.integer  "approved_by"
    t.datetime "approved_at"
    t.string   "created_by"
    t.datetime "created_at",              null: false
  end

  add_index "db_migration", ["approved_by"], name: "db_migration_FI_1", using: :btree

  create_table "db_overage_report", force: true do |t|
    t.integer "account_id",               null: false
    t.string  "company"
    t.string  "country",       limit: 32
    t.string  "state",         limit: 32
    t.integer "type"
    t.integer "db_limit"
    t.integer "total_overage"
    t.date    "overage_date",             null: false
  end

  add_index "db_overage_report", ["account_id", "overage_date"], name: "db_overage_report_lookup", unique: true, using: :btree

  create_table "email_domain", force: true do |t|
    t.string  "domain",     limit: 32
    t.integer "is_isp"
    t.integer "is_popular"
  end

  create_table "email_ip", force: true do |t|
    t.integer "ip_address",                         null: false
    t.string  "hostname",   limit: 128,             null: false
    t.integer "server_id",              default: 0
    t.integer "is_active"
  end

  add_index "email_ip", ["hostname"], name: "ix_hostname", unique: true, using: :btree
  add_index "email_ip", ["ip_address"], name: "ix_ip_address", unique: true, using: :btree

  create_table "email_sending_ip", force: true do |t|
    t.integer "account_id"
    t.integer "ip_address",               null: false
    t.integer "is_dedicated", default: 0
    t.integer "virtual_mta",  default: 0
  end

  add_index "email_sending_ip", ["account_id", "ip_address"], name: "email_sending_ip", unique: true, using: :btree

  create_table "engineer_whitelist", force: true do |t|
    t.string   "ip_address",     limit: 128
    t.text     "note"
    t.datetime "expires"
    t.integer  "status_jumpbox",             default: 0
    t.integer  "status_test",                default: 0
    t.datetime "created_at"
    t.integer  "created_by"
  end

  add_index "engineer_whitelist", ["created_by"], name: "engineer_whitelist_FI_1", using: :btree

  create_table "global_account", force: true do |t|
    t.integer  "email_ip_id"
    t.string   "company"
    t.string   "website"
    t.string   "tracker_domain"
    t.string   "timezone",           limit: 50
    t.string   "encryption_key",     limit: 32
    t.string   "new_encryption_key"
    t.integer  "shard_id",                      default: 1
    t.integer  "type"
    t.integer  "advocate_user_id"
    t.integer  "is_billing_overdue",            default: 0
    t.integer  "is_disabled",                   default: 0
    t.integer  "is_archived",                   default: 0
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_account", ["created_by"], name: "global_account_FI_2", using: :btree
  add_index "global_account", ["email_ip_id"], name: "global_account_FI_1", using: :btree
  add_index "global_account", ["updated_by"], name: "global_account_FI_3", using: :btree

  create_table "global_account_access", force: true do |t|
    t.integer  "account_id", null: false
    t.integer  "role",       null: false
    t.integer  "created_by", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
  end

  add_index "global_account_access", ["account_id"], name: "global_account_access_FI_1", using: :btree
  add_index "global_account_access", ["created_by"], name: "global_account_access_FI_2", using: :btree
  add_index "global_account_access", ["role", "expires_at"], name: "ix_role_expires_at", using: :btree

  create_table "global_account_benchmark_stats", force: true do |t|
    t.integer "account_id",                               null: false
    t.date    "stats_date",                               null: false
    t.integer "logins",                       default: 0
    t.integer "admin_logins",                 default: 0
    t.integer "sales_logins",                 default: 0
    t.integer "emails_sent",                  default: 0
    t.integer "list_emails_sent",             default: 0
    t.integer "plugin_emails_sent",           default: 0
    t.integer "prospects_created",            default: 0
    t.integer "prospects_never_active",       default: 0
    t.integer "visitors_created",             default: 0
    t.integer "visitors_to_delete",           default: 0
    t.integer "content_updated",              default: 0
    t.integer "content_created",              default: 0
    t.integer "score",                        default: 0
    t.integer "percentile",                   default: 0
    t.integer "api_calls",                    default: 0
    t.integer "active_prospects",             default: 0
    t.integer "active_prospects_score",       default: 0
    t.integer "prospects_from_conversions",   default: 0
    t.integer "prospect_page_views",          default: 0
    t.integer "webinars",                     default: 0
    t.integer "webinar_signups",              default: 0
    t.integer "webinar_attendees",            default: 0
    t.integer "landing_page_views",           default: 0
    t.integer "landing_page_errors",          default: 0
    t.integer "landing_page_successes",       default: 0
    t.integer "social_posts",                 default: 0
    t.integer "social_post_clicks",           default: 0
    t.integer "email_opens",                  default: 0
    t.integer "email_clicks",                 default: 0
    t.integer "email_soft_bounces",           default: 0
    t.integer "email_hard_bounces",           default: 0
    t.integer "email_abuse_complaints",       default: 0
    t.integer "email_unsubscribes",           default: 0
    t.integer "opportunities_created",        default: 0
    t.integer "prospect_days_to_opportunity", default: 0
    t.integer "prospect_days_to_close",       default: 0
    t.integer "index_visitors",               default: 0
    t.integer "index_visits",                 default: 0
    t.integer "index_visitor_activities",     default: 0
    t.integer "index_visitor_page_views",     default: 0
    t.integer "index_visitor_referrers",      default: 0
    t.integer "index_prospects",              default: 0
    t.integer "job_drip_program_runs",        default: 0
    t.integer "job_drip_program_time",        default: 0
    t.integer "job_segmentation_runs",        default: 0
    t.integer "job_segmentation_time",        default: 0
    t.integer "job_automation_runs",          default: 0
    t.integer "job_automation_time",          default: 0
    t.integer "job_dynamic_list_runs",        default: 0
    t.integer "job_dynamic_list_time",        default: 0
    t.integer "job_import_runs",              default: 0
    t.integer "job_import_time",              default: 0
    t.integer "job_export_runs",              default: 0
    t.integer "job_export_time",              default: 0
    t.integer "job_crm_sync_runs",            default: 0
    t.integer "job_crm_sync_time",            default: 0
    t.integer "is_archived",                  default: 0
  end

  add_index "global_account_benchmark_stats", ["account_id", "stats_date"], name: "global_account_benchmark_stats_lookup", unique: true, using: :btree

  create_table "global_account_domain", force: true do |t|
    t.integer "account_id",               null: false
    t.string  "domain_name"
    t.integer "spf_verified", default: 0
    t.integer "dk1_verified", default: 0
    t.integer "dk2_verified", default: 0
  end

  add_index "global_account_domain", ["account_id", "domain_name"], name: "global_account_domain", unique: true, using: :btree

  create_table "global_account_domainkey", force: true do |t|
    t.integer "account_id",                          null: false
    t.string  "key_name",    limit: 50, default: ""
    t.text    "private_key"
    t.text    "public_key"
  end

  add_index "global_account_domainkey", ["account_id"], name: "global_account_domainkey_account_id", unique: true, using: :btree

  create_table "global_account_stats", force: true do |t|
    t.integer  "account_id",                                            null: false
    t.date     "stats_date",                                            null: false
    t.datetime "last_login_at"
    t.integer  "logins",                                  default: 0
    t.integer  "admin_logins",                            default: 0
    t.integer  "sales_logins",                            default: 0
    t.integer  "emails_sent",                             default: 0
    t.integer  "list_emails_sent",                        default: 0
    t.integer  "plugin_emails_sent",                      default: 0
    t.integer  "prospects_created",                       default: 0
    t.integer  "prospects_never_active",                  default: 0
    t.integer  "visitors_created",                        default: 0
    t.integer  "visitor_activities",                      default: 0
    t.integer  "visitor_page_views",                      default: 0
    t.integer  "prospect_activities",                     default: 0
    t.integer  "prospect_visitors",                       default: 0
    t.integer  "visitors_to_delete",                      default: 0
    t.integer  "content_updated",                         default: 0
    t.integer  "content_created",                         default: 0
    t.integer  "total_users",                             default: 0
    t.integer  "user_feedback_score",                     default: 0
    t.integer  "user_feedback_entries",                   default: 0
    t.integer  "user_feedback_promoters",                 default: 0
    t.integer  "user_feedback_detractors",                default: 0
    t.integer  "crm_connector",                           default: 0
    t.integer  "active_connectors",                       default: 0
    t.integer  "score",                                   default: 0
    t.float    "percentile",                   limit: 24, default: 0.0
    t.integer  "api_calls",                               default: 0
    t.integer  "active_prospects",                        default: 0
    t.integer  "active_prospects_score",                  default: 0
    t.integer  "prospects_from_conversions",              default: 0
    t.integer  "prospect_page_views",                     default: 0
    t.integer  "webinars",                                default: 0
    t.integer  "webinar_signups",                         default: 0
    t.integer  "webinar_attendees",                       default: 0
    t.integer  "landing_page_views",                      default: 0
    t.integer  "landing_page_errors",                     default: 0
    t.integer  "landing_page_successes",                  default: 0
    t.integer  "social_posts",                            default: 0
    t.integer  "social_post_clicks",                      default: 0
    t.integer  "email_opens",                             default: 0
    t.integer  "email_clicks",                            default: 0
    t.integer  "email_soft_bounces",                      default: 0
    t.integer  "email_hard_bounces",                      default: 0
    t.integer  "email_abuse_complaints",                  default: 0
    t.integer  "email_unsubscribes",                      default: 0
    t.integer  "opportunities_created",                   default: 0
    t.integer  "prospect_days_to_opportunity",            default: 0
    t.integer  "prospect_days_to_close",                  default: 0
    t.integer  "job_drip_program_runs",                   default: 0
    t.integer  "job_drip_program_time",                   default: 0
    t.integer  "job_segmentation_runs",                   default: 0
    t.integer  "job_segmentation_time",                   default: 0
    t.integer  "job_automation_runs",                     default: 0
    t.integer  "job_automation_time",                     default: 0
    t.integer  "job_realtime_automation_runs",            default: 0
    t.integer  "job_realtime_automation_time",            default: 0
    t.integer  "job_dynamic_list_runs",                   default: 0
    t.integer  "job_dynamic_list_time",                   default: 0
    t.integer  "job_import_runs",                         default: 0
    t.integer  "job_import_time",                         default: 0
    t.integer  "job_export_runs",                         default: 0
    t.integer  "job_export_time",                         default: 0
    t.integer  "job_crm_sync_runs",                       default: 0
    t.integer  "job_crm_sync_time",                       default: 0
    t.integer  "is_archived",                             default: 0
  end

  add_index "global_account_stats", ["account_id", "stats_date"], name: "global_account_stats_lookup", unique: true, using: :btree
  add_index "global_account_stats", ["last_login_at"], name: "ix_last_login_at", using: :btree

  create_table "global_agency", force: true do |t|
    t.integer  "account_id", null: false
    t.string   "name"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_agency", ["account_id"], name: "global_agency_account_id_unique", unique: true, using: :btree
  add_index "global_agency", ["created_by"], name: "global_agency_FI_2", using: :btree
  add_index "global_agency", ["updated_by"], name: "global_agency_FI_3", using: :btree

  create_table "global_agency_account", force: true do |t|
    t.integer  "global_agency_id", null: false
    t.integer  "account_id",       null: false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_agency_account", ["account_id"], name: "global_agency_account_account_id_unique", unique: true, using: :btree
  add_index "global_agency_account", ["created_by"], name: "global_agency_account_FI_3", using: :btree
  add_index "global_agency_account", ["global_agency_id"], name: "global_agency_account_FI_1", using: :btree
  add_index "global_agency_account", ["updated_by"], name: "global_agency_account_FI_4", using: :btree

  create_table "global_agency_agency", force: true do |t|
    t.integer  "global_agency_id", null: false
    t.integer  "child_id",         null: false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_agency_agency", ["child_id"], name: "global_agency_agency_child_id_unique", unique: true, using: :btree
  add_index "global_agency_agency", ["created_by"], name: "global_agency_agency_FI_3", using: :btree
  add_index "global_agency_agency", ["global_agency_id"], name: "global_agency_agency_FI_1", using: :btree
  add_index "global_agency_agency", ["updated_by"], name: "global_agency_agency_FI_4", using: :btree

  create_table "global_email_layout", force: true do |t|
    t.string   "name"
    t.text     "html_message"
    t.integer  "global_thumbnail_id"
    t.integer  "is_archived",         default: 0
    t.integer  "is_hidden",           default: 0
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_email_layout", ["created_by"], name: "global_email_layout_FI_2", using: :btree
  add_index "global_email_layout", ["global_thumbnail_id"], name: "global_email_layout_FI_1", using: :btree
  add_index "global_email_layout", ["updated_by"], name: "global_email_layout_FI_3", using: :btree

  create_table "global_memcached_invalidate", force: true do |t|
    t.string "key"
  end

  create_table "global_message", force: true do |t|
    t.text     "content"
    t.integer  "message_type",        null: false
    t.integer  "title_type",          null: false
    t.integer  "system_message_type"
    t.string   "roles"
    t.string   "shards"
    t.string   "categories"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_message", ["created_by"], name: "global_message_FI_1", using: :btree
  add_index "global_message", ["updated_by"], name: "global_message_FI_2", using: :btree

  create_table "global_message_global_account", force: true do |t|
    t.integer "global_message_id", null: false
    t.integer "global_account_id", null: false
  end

  add_index "global_message_global_account", ["global_account_id"], name: "global_message_global_account_FI_2", using: :btree
  add_index "global_message_global_account", ["global_message_id"], name: "global_message_global_account_FI_1", using: :btree

  create_table "global_setting", force: true do |t|
    t.string "setting_key",   limit: 64
    t.text   "setting_value"
  end

  add_index "global_setting", ["setting_key"], name: "ix_setting_key", unique: true, using: :btree

  create_table "global_thumbnail", force: true do |t|
    t.string   "s3_key",      limit: 100
    t.integer  "is_archived",             default: 0
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_thumbnail", ["created_by"], name: "global_thumbnail_FI_1", using: :btree
  add_index "global_thumbnail", ["updated_by"], name: "global_thumbnail_FI_2", using: :btree

  create_table "global_user", force: true do |t|
    t.integer  "account_id",                                       null: false
    t.string   "email",                    limit: 64
    t.string   "password",                 limit: 100
    t.integer  "role",                                             null: false
    t.string   "rss_key",                  limit: 32
    t.string   "crm_username"
    t.string   "crm_user_fid",             limit: 50
    t.integer  "is_archived",                          default: 0
    t.integer  "is_crm_username_verified",             default: 0
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_user", ["account_id"], name: "global_user_FI_1", using: :btree
  add_index "global_user", ["created_by"], name: "global_user_FI_2", using: :btree
  add_index "global_user", ["email"], name: "global_user_email_unique", unique: true, using: :btree
  add_index "global_user", ["updated_by"], name: "global_user_FI_3", using: :btree

  create_table "global_user_feedback", force: true do |t|
    t.integer  "account_id",   null: false
    t.integer  "user_id",      null: false
    t.integer  "time_period",  null: false
    t.integer  "response",     null: false
    t.text     "comments"
    t.integer  "is_responded"
    t.datetime "created_at"
  end

  add_index "global_user_feedback", ["account_id"], name: "global_user_feedback_FI_1", using: :btree
  add_index "global_user_feedback", ["user_id"], name: "global_user_feedback_FI_2", using: :btree

  create_table "global_user_login", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "ip_address",      limit: 15
    t.integer  "is_successful",               default: 1
    t.integer  "is_persistent",               default: 0, null: false
    t.string   "remember_me_key", limit: 128
    t.datetime "expires_at"
    t.string   "preview_key",     limit: 128
    t.datetime "created_at"
  end

  add_index "global_user_login", ["account_id"], name: "global_user_login_FI_1", using: :btree
  add_index "global_user_login", ["preview_key"], name: "uniq_preview_key", unique: true, using: :btree
  add_index "global_user_login", ["remember_me_key"], name: "uniq_remember_me_key", unique: true, using: :btree
  add_index "global_user_login", ["user_id"], name: "global_user_login_FI_2", using: :btree

  create_table "job", force: true do |t|
    t.integer  "job_group_id"
    t.integer  "shard_id",                    default: 1
    t.integer  "status",                      default: 0
    t.integer  "requested_status",            default: 0
    t.text     "params"
    t.datetime "created_at"
    t.datetime "last_tried_at"
    t.float    "runtime",          limit: 24
    t.datetime "scheduled_at"
    t.integer  "server_id",                   default: 0
    t.integer  "launcher_pid"
    t.integer  "pid"
  end

  add_index "job", ["job_group_id", "shard_id"], name: "job_shard", unique: true, using: :btree
  add_index "job", ["server_id", "status"], name: "ix_server_id", using: :btree

  create_table "job_category", force: true do |t|
    t.string "name", limit: 50
  end

  add_index "job_category", ["name"], name: "job_category_name", unique: true, using: :btree

  create_table "job_group", force: true do |t|
    t.integer  "job_category_id"
    t.string   "name",            limit: 50
    t.string   "type",            limit: 50
    t.integer  "server_location"
    t.integer  "retry_delay",                default: 600
    t.integer  "max_runtime",                default: 3600
    t.integer  "auto_kill",                  default: 0
    t.text     "params"
    t.datetime "created_at"
    t.time     "scheduled_time"
  end

  add_index "job_group", ["job_category_id"], name: "job_group_FI_1", using: :btree
  add_index "job_group", ["name"], name: "job_group_name", unique: true, using: :btree

  create_table "job_host", force: true do |t|
    t.string   "server_name",      limit: 50
    t.integer  "requested_status",            default: 0
    t.datetime "manager_run_at"
  end

  add_index "job_host", ["server_name"], name: "job_host_server_name", unique: true, using: :btree

  create_table "job_server", force: true do |t|
    t.integer "shard_id",                   default: 1
    t.string  "server_name",     limit: 50
    t.integer "server_location"
  end

  add_index "job_server", ["shard_id", "server_location"], name: "job_server", unique: true, using: :btree

  create_table "outlook_error", force: true do |t|
    t.integer  "account_id"
    t.text     "error_message"
    t.text     "json"
    t.string   "hash"
    t.datetime "created_at"
  end

  add_index "outlook_error", ["account_id"], name: "outlook_error_FI_1", using: :btree

  create_table "pardotexplorer_queries", force: true do |t|
    t.integer  "user_id"
    t.string   "database"
    t.string   "datacenter"
    t.integer  "account_id"
    t.text     "sql"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recent_releases", force: true do |t|
    t.integer  "user_id",         null: false
    t.string   "title"
    t.text     "description"
    t.datetime "release_date"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recent_releases", ["user_id"], name: "recent_releases_FI_1", using: :btree

  create_table "rss_feed", force: true do |t|
    t.integer  "feed_type"
    t.string   "feed_id",     limit: 64
    t.string   "url",         limit: 512
    t.string   "title",       limit: 512
    t.text     "description"
    t.string   "author",      limit: 64
    t.datetime "created"
    t.datetime "updated"
  end

  add_index "rss_feed", ["feed_id"], name: "ix_feed_id", using: :btree
  add_index "rss_feed", ["feed_type", "created"], name: "ix_type_created", using: :btree
  add_index "rss_feed", ["feed_type", "feed_id"], name: "ix_feed_type_id", unique: true, using: :btree

  create_table "spam_ip", force: true do |t|
    t.string   "ip",           limit: 40, null: false
    t.datetime "last_seen_at",            null: false
  end

  add_index "spam_ip", ["ip"], name: "ix_ip", unique: true, using: :btree
  add_index "spam_ip", ["last_seen_at"], name: "ix_last_seen_at", using: :btree

  create_table "user_sso_login", force: true do |t|
    t.integer  "account_id",             null: false
    t.integer  "user_id",                null: false
    t.integer  "sso_type"
    t.string   "sso_id"
    t.string   "sso_id_endpoint_url"
    t.string   "sso_org_id"
    t.string   "sso_username"
    t.string   "access_token"
    t.string   "refresh_token"
    t.string   "instance_url"
    t.string   "ld_access_token"
    t.string   "ld_refresh_token"
    t.string   "ld_sso_id_endpoint_url"
    t.string   "ld_sso_id"
    t.string   "ld_instance_url"
    t.datetime "created_at",             null: false
  end

  add_index "user_sso_login", ["account_id"], name: "user_sso_login_FI_1", using: :btree
  add_index "user_sso_login", ["sso_type", "sso_id"], name: "sso_unique", unique: true, using: :btree
  add_index "user_sso_login", ["user_id"], name: "user_sso_login_FI_2", using: :btree

  create_table "virtual_server", force: true do |t|
    t.integer  "type",                    null: false
    t.integer  "status",      default: 0
    t.text     "ip_address",              null: false
    t.text     "hostname",                null: false
    t.integer  "created_by"
    t.datetime "created_at",              null: false
    t.integer  "is_archived", default: 0
  end

  add_index "virtual_server", ["created_by"], name: "virtual_server_FI_1", using: :btree

end

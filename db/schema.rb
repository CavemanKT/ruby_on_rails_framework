# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_04_151334) do
  create_table "admin_actions", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.string "action_type", null: false
    t.string "target_type"
    t.integer "target_id"
    t.json "details"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_admin_actions_on_action_type"
    t.index ["admin_id", "created_at"], name: "index_admin_actions_on_admin_id_and_created_at"
    t.index ["admin_id"], name: "index_admin_actions_on_admin_id"
    t.index ["created_at"], name: "index_admin_actions_on_created_at"
    t.index ["target_type", "target_id"], name: "index_admin_actions_on_target_type_and_target_id"
  end

  create_table "bans", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "admin_id", null: false
    t.text "reason", null: false
    t.datetime "expires_at"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_bans_on_admin_id"
    t.index ["expires_at"], name: "index_bans_on_expires_at"
    t.index ["user_id", "is_active"], name: "index_bans_on_user_id_and_is_active"
    t.index ["user_id"], name: "index_bans_on_user_id"
  end

  create_table "breathing_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "duration"
    t.boolean "completed"
    t.integer "calm_points_earned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_breathing_sessions_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "user_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "content"
    t.integer "visibility"
    t.integer "likes_count"
    t.integer "comments_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "reporter_id", null: false
    t.string "reportable_type", null: false
    t.integer "reportable_id", null: false
    t.integer "reason", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.integer "admin_id"
    t.text "admin_note"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_reports_on_admin_id"
    t.index ["created_at"], name: "index_reports_on_created_at"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "first_name"
    t.string "middle_initial", limit: 1
    t.string "last_name"
    t.string "tel"
    t.boolean "allow_sms_messages", default: true, null: false
    t.boolean "allow_email_messages", default: true, null: false
    t.string "nickname"
    t.string "avatar_url"
    t.text "bio"
    t.integer "calm_points"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["first_name", "last_name"], name: "index_users_on_first_name_and_last_name"
    t.index ["role"], name: "index_users_on_role"
    t.index ["tel"], name: "index_users_on_tel"
  end

  add_foreign_key "admin_actions", "users", column: "admin_id"
  add_foreign_key "bans", "users"
  add_foreign_key "bans", "users", column: "admin_id"
  add_foreign_key "breathing_sessions", "users"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "reports", "users", column: "admin_id"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "sessions", "users"
end

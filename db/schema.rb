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

ActiveRecord::Schema.define(version: 2020_01_14_022139) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "clubs", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "conference", limit: 255
    t.integer "primary_color"
    t.integer "secondary_color"
    t.integer "accent_color"
    t.string "abbrv", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "crest_file_name", limit: 255
    t.string "crest_content_type", limit: 255
    t.integer "crest_file_size"
    t.datetime "crest_updated_at"
    t.integer "api_id", null: false
    t.index ["conference"], name: "index_clubs_on_conference"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.datetime "kickoff"
    t.string "location", limit: 255
    t.integer "home_goals", limit: 2
    t.integer "away_goals", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "uid", limit: 255
    t.integer "season"
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["home_team_id", "away_team_id"], name: "index_matches_on_home_team_id_and_away_team_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
    t.index ["uid"], name: "index_matches_on_uid"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "year"
    t.hstore "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json "privileges"
    t.string "type", limit: 255
    t.integer "family_id"
    t.text "refunded"
    t.string "stripe_charge_id"
    t.string "stripe_subscription_id"
    t.index ["info"], name: "index_memberships_on_info", using: :gist
    t.index ["stripe_charge_id"], name: "index_memberships_on_stripe_charge_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
    t.index ["year", "stripe_subscription_id"], name: "index_memberships_on_year_and_stripe_subscription_id", unique: true
  end

  create_table "mot_ms", force: :cascade do |t|
    t.integer "user_id"
    t.integer "match_id"
    t.integer "first_id"
    t.integer "second_id"
    t.integer "third_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "match_id"], name: "index_mot_ms_on_user_id_and_match_id", unique: true
  end

  create_table "pick_ems", force: :cascade do |t|
    t.integer "match_id"
    t.integer "user_id"
    t.integer "result", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "correct"
    t.index ["match_id", "user_id"], name: "index_pick_ems_on_match_id_and_user_id", unique: true
    t.index ["match_id"], name: "index_pick_ems_on_match_id"
    t.index ["user_id"], name: "index_pick_ems_on_user_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.integer "club_id"
    t.string "position", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "number", limit: 2
    t.boolean "active", default: true
    t.index ["club_id"], name: "index_players_on_club_id"
  end

  create_table "rev_guesses", force: :cascade do |t|
    t.integer "match_id"
    t.integer "user_id"
    t.integer "home_goals"
    t.integer "away_goals"
    t.string "comment", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "score"
    t.index ["match_id", "user_id"], name: "index_rev_guesses_on_match_id_and_user_id", unique: true
    t.index ["match_id"], name: "index_rev_guesses_on_match_id"
    t.index ["user_id"], name: "index_rev_guesses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "last_name", limit: 255
    t.string "first_name", limit: 255
    t.string "address", limit: 255
    t.string "city", limit: 255
    t.string "state", limit: 255
    t.string "postal_code", limit: 255
    t.bigint "phone"
    t.string "email", limit: 255, default: "", null: false
    t.string "username", limit: 255, default: "", null: false
    t.integer "member_since"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "stripe_customer_token", limit: 255
    t.string "country", limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.string "whodunnit", limit: 255
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end

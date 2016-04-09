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

ActiveRecord::Schema.define(version: 20160409200748) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"

  create_table "clubs", force: true do |t|
    t.string   "name"
    t.string   "conference"
    t.integer  "primary_color"
    t.integer  "secondary_color"
    t.integer  "accent_color"
    t.string   "abbrv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crest_file_name"
    t.string   "crest_content_type"
    t.integer  "crest_file_size"
    t.datetime "crest_updated_at"
  end

  add_index "clubs", ["conference"], name: "index_clubs_on_conference", using: :btree

  create_table "matches", force: true do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.datetime "kickoff"
    t.string   "location"
    t.integer  "home_goals",   limit: 2
    t.integer  "away_goals",   limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uid"
    t.integer  "season"
  end

  add_index "matches", ["away_team_id"], name: "index_matches_on_away_team_id", using: :btree
  add_index "matches", ["home_team_id", "away_team_id"], name: "index_matches_on_home_team_id_and_away_team_id", using: :btree
  add_index "matches", ["home_team_id"], name: "index_matches_on_home_team_id", using: :btree
  add_index "matches", ["uid"], name: "index_matches_on_uid", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "year"
    t.hstore   "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "privileges"
    t.string   "type"
    t.integer  "family_id"
    t.text     "refunded"
  end

  add_index "memberships", ["info"], name: "index_memberships_on_info", using: :gist
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "mot_ms", force: true do |t|
    t.integer  "user_id"
    t.integer  "match_id"
    t.integer  "first_id"
    t.integer  "second_id"
    t.integer  "third_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mot_ms", ["user_id", "match_id"], name: "index_mot_ms_on_user_id_and_match_id", unique: true, using: :btree

  create_table "pick_ems", force: true do |t|
    t.integer  "match_id"
    t.integer  "user_id"
    t.integer  "result",     limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "correct"
  end

  add_index "pick_ems", ["match_id", "user_id"], name: "index_pick_ems_on_match_id_and_user_id", unique: true, using: :btree
  add_index "pick_ems", ["match_id"], name: "index_pick_ems_on_match_id", using: :btree
  add_index "pick_ems", ["user_id"], name: "index_pick_ems_on_user_id", using: :btree

  create_table "players", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "club_id"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number",     limit: 2
    t.boolean  "active",               default: true
  end

  add_index "players", ["club_id"], name: "index_players_on_club_id", using: :btree

  create_table "rev_guesses", force: true do |t|
    t.integer  "match_id"
    t.integer  "user_id"
    t.integer  "home_goals"
    t.integer  "away_goals"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score"
  end

  add_index "rev_guesses", ["match_id", "user_id"], name: "index_rev_guesses_on_match_id_and_user_id", unique: true, using: :btree
  add_index "rev_guesses", ["match_id"], name: "index_rev_guesses_on_match_id", using: :btree
  add_index "rev_guesses", ["user_id"], name: "index_rev_guesses_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.integer  "phone",                  limit: 8
    t.string   "email",                            default: "", null: false
    t.string   "username",                         default: "", null: false
    t.integer  "member_since"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",               default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "stripe_customer_token"
    t.string   "country"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end

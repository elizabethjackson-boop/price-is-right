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

ActiveRecord::Schema[8.1].define(version: 2026_04_07_223816) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "current_round", default: 0, null: false
    t.string "state", default: "waiting", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guesses", force: :cascade do |t|
    t.integer "amount"
    t.datetime "created_at", null: false
    t.integer "diff"
    t.bigint "player_id", null: false
    t.integer "points", default: 0, null: false
    t.string "result"
    t.integer "round"
    t.integer "speed_bonus", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "round"], name: "index_guesses_on_player_id_and_round", unique: true
    t.index ["player_id"], name: "index_guesses_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.string "name"
    t.integer "score", default: 0, null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  add_foreign_key "guesses", "players"
  add_foreign_key "players", "games"
end

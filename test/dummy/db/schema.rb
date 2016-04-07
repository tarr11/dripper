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

ActiveRecord::Schema.define(version: 20160407005342) do

  create_table "dripper_actions", force: :cascade do |t|
    t.string   "mailer",     null: false
    t.string   "action",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dripper_messages", force: :cascade do |t|
    t.integer  "drippable_id",      null: false
    t.string   "drippable_type",    null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "dripper_action_id"
  end

  add_index "dripper_messages", ["drippable_type", "drippable_id"], name: "index_dripper_messages_on_drippable_type_and_drippable_id"
  add_index "dripper_messages", ["dripper_action_id"], name: "index_dripper_messages_on_dripper_action_id"

  create_table "newsletters", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "newsletters", ["user_id"], name: "index_newsletters_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

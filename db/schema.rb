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

ActiveRecord::Schema.define(version: 20150303013457) do

  create_table "certificate_authorities", force: true do |t|
    t.string   "name"
    t.text     "private_key"
    t.text     "ca_cert"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "next_serial"
  end

  create_table "certificates", force: true do |t|
    t.text     "cert"
    t.integer  "serial"
    t.integer  "certificate_authority_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "certificates", ["certificate_authority_id", "serial"], name: "index_certificates_on_certificate_authority_id_and_serial", unique: true

end

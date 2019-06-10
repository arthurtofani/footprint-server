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

ActiveRecord::Schema.define(version: 2019_05_15_014544) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "buckets", force: :cascade do |t|
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "amnt_digests", default: 0
    t.index ["slug"], name: "index_buckets_on_slug"
  end

  create_table "digest_locations", force: :cascade do |t|
    t.integer "time_offset_ms"
    t.bigint "hash_digest_id"
    t.bigint "medium_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tf"
    t.index ["hash_digest_id"], name: "index_digest_locations_on_hash_digest_id"
    t.index ["medium_id"], name: "index_digest_locations_on_medium_id"
  end

  create_table "hash_digests", force: :cascade do |t|
    t.string "digest", null: false
    t.bigint "bucket_id"
    t.integer "freq", default: 1
    t.index ["bucket_id"], name: "index_hash_digests_on_bucket_id"
    t.index ["digest", "bucket_id"], name: "index_hash_digests_on_digest_and_bucket_id", unique: true
    t.index ["digest"], name: "index_hash_digests_on_digest"
    t.index ["freq"], name: "index_hash_digests_on_freq"
  end

  create_table "media", force: :cascade do |t|
    t.string "path"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bucket_id"
    t.index ["bucket_id"], name: "index_media_on_bucket_id"
  end

  create_table "temp_digests", force: :cascade do |t|
    t.bigint "medium_id"
    t.string "digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time_offset_ms"
    t.index ["digest"], name: "index_temp_digests_on_digest"
    t.index ["medium_id"], name: "index_temp_digests_on_medium_id"
  end

  add_foreign_key "digest_locations", "hash_digests"
  add_foreign_key "digest_locations", "media"
  add_foreign_key "hash_digests", "buckets", on_delete: :cascade
  add_foreign_key "media", "buckets", on_delete: :cascade
  add_foreign_key "temp_digests", "media"
end

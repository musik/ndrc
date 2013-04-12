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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121227205225) do

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.string  "slug"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "depth"
    t.integer "cid"
  end

  add_index "categories", ["parent_id", "lft", "rgt"], :name => "plr"
  add_index "categories", ["slug"], :name => "index_categories_on_slug"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.integer  "province_id"
    t.integer  "level"
    t.string   "zip_code"
    t.string   "pinyin"
    t.string   "pinyin_abbr"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "cities", ["level"], :name => "index_cities_on_level"
  add_index "cities", ["name"], :name => "index_cities_on_name"
  add_index "cities", ["pinyin"], :name => "index_cities_on_pinyin"
  add_index "cities", ["pinyin_abbr"], :name => "index_cities_on_pinyin_abbr"
  add_index "cities", ["province_id"], :name => "index_cities_on_province_id"
  add_index "cities", ["zip_code"], :name => "index_cities_on_zip_code"

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "fuwu"
    t.string   "hangye"
    t.string   "location"
    t.string   "ali_url"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "delta",      :default => true, :null => false
  end

  add_index "companies", ["ali_url"], :name => "index_companies_on_ali_url"
  add_index "companies", ["delta"], :name => "index_companies_on_delta"

  create_table "company_meta", :force => true do |t|
    t.string  "mkey"
    t.string  "mval"
    t.integer "company_id"
  end

  add_index "company_meta", ["company_id", "mkey"], :name => "cmeta"

  create_table "company_texts", :force => true do |t|
    t.text    "body"
    t.integer "company_id"
  end

  add_index "company_texts", ["company_id"], :name => "index_company_texts_on_company_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "districts", :force => true do |t|
    t.string   "name"
    t.integer  "city_id"
    t.string   "pinyin"
    t.string   "pinyin_abbr"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "districts", ["city_id"], :name => "index_districts_on_city_id"
  add_index "districts", ["name"], :name => "index_districts_on_name"
  add_index "districts", ["pinyin"], :name => "index_districts_on_pinyin"
  add_index "districts", ["pinyin_abbr"], :name => "index_districts_on_pinyin_abbr"

  create_table "provinces", :force => true do |t|
    t.string   "name"
    t.string   "pinyin"
    t.string   "pinyin_abbr"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "provinces", ["name"], :name => "index_provinces_on_name"
  add_index "provinces", ["pinyin"], :name => "index_provinces_on_pinyin"
  add_index "provinces", ["pinyin_abbr"], :name => "index_provinces_on_pinyin_abbr"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "snips", :force => true do |t|
    t.string "name"
    t.text   "data"
  end

  add_index "snips", ["name"], :name => "index_snips_on_name"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end

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

ActiveRecord::Schema[7.1].define(version: 2024_05_22_141156) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "kind", default: "bank", null: false
    t.string "currency", limit: 3, null: false
    t.bigint "opening_balance_cents", default: 0, null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_accounts_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "budgets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.date "month", null: false
    t.bigint "amount_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_budgets_on_category_id"
    t.index ["user_id", "category_id", "month"], name: "index_budgets_on_user_id_and_category_id_and_month", unique: true
    t.index ["user_id"], name: "index_budgets_on_user_id"
    t.check_constraint "amount_cents > 0", name: "budgets_amount_positive"
    t.check_constraint "month = date_trunc('month'::text, month::timestamp with time zone)::date", name: "budgets_month_is_first_day"
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "kind", default: "expense", null: false
    t.string "color", default: "slate", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "kind", "name"], name: "index_categories_on_user_id_and_kind_and_name", unique: true
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "goals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id"
    t.string "name", null: false
    t.bigint "target_cents", null: false
    t.bigint "saved_cents", default: 0, null: false
    t.date "target_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_goals_on_account_id"
    t.index ["user_id"], name: "index_goals_on_user_id"
    t.check_constraint "target_cents > 0", name: "goals_target_positive"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "imports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.string "filename", null: false
    t.text "raw_csv", null: false
    t.jsonb "mapping", default: {}, null: false
    t.string "status", default: "uploaded", null: false
    t.integer "imported_count", default: 0, null: false
    t.integer "skipped_count", default: 0, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_imports_on_account_id"
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "recurring_transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.bigint "category_id"
    t.string "kind", default: "expense", null: false
    t.bigint "amount_cents", null: false
    t.string "description", null: false
    t.string "frequency", default: "monthly", null: false
    t.date "next_on", null: false
    t.date "ends_on"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_recurring_transactions_on_account_id"
    t.index ["active", "next_on"], name: "index_recurring_transactions_on_active_and_next_on"
    t.index ["category_id"], name: "index_recurring_transactions_on_category_id"
    t.index ["user_id"], name: "index_recurring_transactions_on_user_id"
    t.check_constraint "amount_cents > 0", name: "recurring_transactions_amount_positive"
  end

  create_table "rules", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "pattern", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "user_id, lower((pattern)::text)", name: "index_rules_on_user_id_and_lower_pattern", unique: true
    t.index ["category_id"], name: "index_rules_on_category_id"
    t.index ["user_id"], name: "index_rules_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["transaction_id", "tag_id"], name: "index_taggings_on_transaction_id_and_tag_id", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "user_id, lower((name)::text)", name: "index_tags_on_user_id_and_lower_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.bigint "category_id"
    t.string "kind", default: "expense", null: false
    t.bigint "amount_cents", null: false
    t.date "occurred_on", null: false
    t.string "description", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "import_id"
    t.index ["account_id", "occurred_on"], name: "index_transactions_on_account_id_and_occurred_on"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["import_id"], name: "index_transactions_on_import_id"
    t.index ["user_id", "occurred_on"], name: "index_transactions_on_user_id_and_occurred_on"
    t.index ["user_id"], name: "index_transactions_on_user_id"
    t.check_constraint "amount_cents > 0", name: "transactions_amount_positive"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "from_account_id", null: false
    t.bigint "to_account_id", null: false
    t.bigint "amount_cents", null: false
    t.date "occurred_on", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_account_id"], name: "index_transfers_on_from_account_id"
    t.index ["to_account_id"], name: "index_transfers_on_to_account_id"
    t.index ["user_id", "occurred_on"], name: "index_transfers_on_user_id_and_occurred_on"
    t.index ["user_id"], name: "index_transfers_on_user_id"
    t.check_constraint "amount_cents > 0", name: "transfers_amount_positive"
    t.check_constraint "from_account_id <> to_account_id", name: "transfers_distinct_accounts"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "currency", limit: 3, default: "PKR", null: false
    t.string "time_zone", default: "Karachi", null: false
    t.boolean "monthly_summary", default: true, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "budgets", "categories", on_delete: :cascade
  add_foreign_key "budgets", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "goals", "accounts", on_delete: :nullify
  add_foreign_key "goals", "users"
  add_foreign_key "imports", "accounts"
  add_foreign_key "imports", "users"
  add_foreign_key "recurring_transactions", "accounts"
  add_foreign_key "recurring_transactions", "categories", on_delete: :nullify
  add_foreign_key "recurring_transactions", "users"
  add_foreign_key "rules", "categories", on_delete: :cascade
  add_foreign_key "rules", "users"
  add_foreign_key "taggings", "tags", on_delete: :cascade
  add_foreign_key "taggings", "transactions", on_delete: :cascade
  add_foreign_key "tags", "users"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "imports", on_delete: :nullify
  add_foreign_key "transactions", "users"
  add_foreign_key "transfers", "accounts", column: "from_account_id"
  add_foreign_key "transfers", "accounts", column: "to_account_id"
  add_foreign_key "transfers", "users"
end

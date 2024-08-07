class CreateDeletions < ActiveRecord::Migration[7.1]
  def change
    create_table :deletions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.datetime :deleted_at, null: false
    end

    add_index :deletions, [ :user_id, :deleted_at ]
  end
end

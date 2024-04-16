class CreateImports < ActiveRecord::Migration[7.1]
  def change
    create_table :imports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :filename, null: false
      t.text :raw_csv, null: false
      t.jsonb :mapping, null: false, default: {}
      t.string :status, null: false, default: "uploaded"
      t.integer :imported_count, null: false, default: 0
      t.integer :skipped_count, null: false, default: 0
      t.datetime :completed_at

      t.timestamps
    end
  end
end

class CreateRules < ActiveRecord::Migration[7.1]
  def change
    create_table :rules do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: { on_delete: :cascade }
      t.string :pattern, null: false

      t.timestamps
    end

    add_index :rules, "user_id, lower(pattern)", unique: true, name: "index_rules_on_user_id_and_lower_pattern"
  end
end

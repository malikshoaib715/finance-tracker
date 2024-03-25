class CreateBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: { on_delete: :cascade }
      t.date :month, null: false
      t.bigint :amount_cents, null: false

      t.timestamps
    end

    add_index :budgets, [ :user_id, :category_id, :month ], unique: true
    add_check_constraint :budgets, "amount_cents > 0", name: "budgets_amount_positive"
    add_check_constraint :budgets, "month = date_trunc('month', month)::date", name: "budgets_month_is_first_day"
  end
end

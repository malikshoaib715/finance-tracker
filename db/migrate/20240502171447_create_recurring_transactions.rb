class CreateRecurringTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :recurring_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :category, foreign_key: { on_delete: :nullify }
      t.string :kind, null: false, default: "expense"
      t.bigint :amount_cents, null: false
      t.string :description, null: false
      t.string :frequency, null: false, default: "monthly"
      t.date :next_on, null: false
      t.date :ends_on
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :recurring_transactions, [ :active, :next_on ]
    add_check_constraint :recurring_transactions, "amount_cents > 0", name: "recurring_transactions_amount_positive"
  end
end

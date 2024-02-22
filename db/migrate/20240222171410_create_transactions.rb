class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.string :kind, null: false, default: "expense"
      t.bigint :amount_cents, null: false
      t.date :occurred_on, null: false
      t.string :description, null: false
      t.text :notes

      t.timestamps
    end

    add_index :transactions, [ :user_id, :occurred_on ]
    add_index :transactions, [ :account_id, :occurred_on ]
    add_check_constraint :transactions, "amount_cents > 0", name: "transactions_amount_positive"
  end
end

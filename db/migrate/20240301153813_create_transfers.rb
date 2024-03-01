class CreateTransfers < ActiveRecord::Migration[7.1]
  def change
    create_table :transfers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :from_account, null: false, foreign_key: { to_table: :accounts }
      t.references :to_account, null: false, foreign_key: { to_table: :accounts }
      t.bigint :amount_cents, null: false
      t.date :occurred_on, null: false
      t.string :description

      t.timestamps
    end

    add_index :transfers, [ :user_id, :occurred_on ]
    add_check_constraint :transfers, "amount_cents > 0", name: "transfers_amount_positive"
    add_check_constraint :transfers, "from_account_id <> to_account_id", name: "transfers_distinct_accounts"
  end
end

class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :kind, null: false, default: "bank"
      t.string :currency, null: false, limit: 3
      t.bigint :opening_balance_cents, null: false, default: 0
      t.datetime :archived_at

      t.timestamps
    end

    add_index :accounts, [ :user_id, :name ], unique: true
  end
end

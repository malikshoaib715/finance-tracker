class CreateSubscriptionEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_events do |t|
      t.references :subscription, null: false, foreign_key: { on_delete: :cascade }
      t.string :kind, null: false
      t.date :occurred_on, null: false
      t.bigint :amount_cents
      t.string :currency, limit: 3
      t.string :card_last4, limit: 4
      # Evidence, never the email body: where the fact came from.
      t.string :source, null: false
      t.string :source_ref
      t.string :evidence

      t.timestamps
    end

    add_index :subscription_events, [ :subscription_id, :occurred_on ]
    add_index :subscription_events, [ :source, :source_ref ], unique: true, where: "source_ref IS NOT NULL"
  end
end

class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :service, null: false
      t.string :plan
      t.bigint :amount_cents
      t.string :currency, limit: 3
      t.string :interval, null: false, default: "monthly"
      t.string :status, null: false, default: "active"
      t.string :billed_via, null: false, default: "direct"
      t.string :card_last4, limit: 4
      t.date :last_charged_on
      t.date :next_renewal_on

      t.timestamps
    end

    add_index :subscriptions, "user_id, lower(service)", unique: true, name: "index_subscriptions_on_user_and_service"
  end
end

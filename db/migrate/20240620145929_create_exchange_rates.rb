class CreateExchangeRates < ActiveRecord::Migration[7.1]
  def change
    create_table :exchange_rates do |t|
      t.references :user, null: false, foreign_key: true
      t.string :currency, null: false, limit: 3
      t.decimal :rate, null: false, precision: 18, scale: 6

      t.timestamps
    end

    add_index :exchange_rates, [ :user_id, :currency ], unique: true
    add_check_constraint :exchange_rates, "rate > 0", name: "exchange_rates_rate_positive"
  end
end

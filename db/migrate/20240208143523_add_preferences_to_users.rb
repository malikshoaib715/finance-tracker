class AddPreferencesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :currency, :string, limit: 3, null: false, default: "PKR"
    add_column :users, :time_zone, :string, null: false, default: "Karachi"
  end
end

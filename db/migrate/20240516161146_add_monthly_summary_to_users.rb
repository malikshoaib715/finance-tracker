class AddMonthlySummaryToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :monthly_summary, :boolean, null: false, default: true
  end
end

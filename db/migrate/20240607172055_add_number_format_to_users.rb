class AddNumberFormatToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :number_format, :string, null: false, default: "international"
  end
end

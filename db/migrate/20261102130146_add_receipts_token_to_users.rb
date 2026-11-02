class AddReceiptsTokenToUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :users, :receipts_token, :string
    add_index :users, :receipts_token, unique: true, algorithm: :concurrently
  end
end

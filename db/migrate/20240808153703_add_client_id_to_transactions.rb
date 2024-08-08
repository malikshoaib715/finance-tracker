# Offline clients generate a UUID per transaction so a retried POST can't
# create a duplicate.
class AddClientIdToTransactions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :transactions, :client_id, :uuid
    add_index :transactions, [ :user_id, :client_id ], unique: true, where: "client_id IS NOT NULL", algorithm: :concurrently
  end
end

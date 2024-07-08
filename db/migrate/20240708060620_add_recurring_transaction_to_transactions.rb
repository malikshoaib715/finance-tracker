class AddRecurringTransactionToTransactions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :transactions, :recurring_transaction, index: { algorithm: :concurrently }
    add_foreign_key :transactions, :recurring_transactions, on_delete: :nullify, validate: false
  end
end

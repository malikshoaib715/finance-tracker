# The sync API pages through a user's changes ordered by (updated_at, id).
class AddUpdatedAtIndexToTransactions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :transactions, [ :user_id, :updated_at, :id ], algorithm: :concurrently
  end
end

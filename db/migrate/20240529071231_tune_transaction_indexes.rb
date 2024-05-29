# Budget and category queries filter by category and date; the single-column
# user_id and account_id indexes are already covered by the composite indexes
# that lead with those columns, so they only cost write time.
class TuneTransactionIndexes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :transactions, [ :category_id, :occurred_on ], algorithm: :concurrently, if_not_exists: true
    remove_index :transactions, :category_id, algorithm: :concurrently, if_exists: true
    remove_index :transactions, :account_id, algorithm: :concurrently, if_exists: true
    remove_index :transactions, :user_id, algorithm: :concurrently, if_exists: true
  end
end

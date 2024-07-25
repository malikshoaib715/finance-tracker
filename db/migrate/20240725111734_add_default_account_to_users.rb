class AddDefaultAccountToUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :users, :default_account, index: { algorithm: :concurrently }
    add_foreign_key :users, :accounts, column: :default_account_id, on_delete: :nullify, validate: false
  end
end

class ValidateUsersDefaultAccountForeignKey < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :users, :accounts, column: :default_account_id
  end
end

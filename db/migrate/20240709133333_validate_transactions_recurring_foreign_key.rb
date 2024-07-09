# Second step of adding the foreign key: validating separately avoids holding a
# lock on transactions while every existing row is checked.
class ValidateTransactionsRecurringForeignKey < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :transactions, :recurring_transactions
  end
end

require "test_helper"

class RecurringTransactionTest < ActiveSupport::TestCase
  test "steps forward by its frequency" do
    item = recurring_transactions(:rent)
    assert_equal Date.new(2024, 2, 29), item.following(Date.new(2024, 1, 31))
    item.frequency = "weekly"
    assert_equal Date.new(2024, 5, 9), item.following(Date.new(2024, 5, 2))
    item.frequency = "yearly"
    assert_equal Date.new(2025, 2, 28), item.following(Date.new(2024, 2, 29))
  end

  test "due only includes active items on or before the date" do
    assert_equal [ recurring_transactions(:rent) ], users(:ayesha).recurring_transactions.due.to_a
  end

  test "end date must not be before the next date" do
    item = recurring_transactions(:rent)
    item.ends_on = item.next_on - 1
    assert_not item.valid?
  end

  test "rejects unknown frequencies" do
    item = recurring_transactions(:rent)
    item.frequency = "fortnightly"
    assert_not item.valid?
  end
end

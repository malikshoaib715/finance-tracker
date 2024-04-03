require "test_helper"

class Reports::CategoryBreakdownTest < ActiveSupport::TestCase
  test "ranks categories by spending with share and change" do
    users(:ayesha).transactions.create!(account: accounts(:ayesha_cash), category: categories(:ayesha_groceries),
      kind: "expense", amount: "1000", occurred_on: Date.current.prev_month, description: "Last month shop")

    rows = Reports::CategoryBreakdown.new(users(:ayesha)).rows

    assert_equal %w[Rent Groceries], rows.map(&:name)
    assert_in_delta 0.937, rows.first.share, 0.001
    assert_equal 435_000 - 100_000, rows.second.change_cents
  end

  test "groups transactions without a category" do
    transactions(:groceries).update!(category: nil)
    assert_includes Reports::CategoryBreakdown.new(users(:ayesha)).rows.map(&:name), "Uncategorised"
  end
end

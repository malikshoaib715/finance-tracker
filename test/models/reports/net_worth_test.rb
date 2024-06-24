require "test_helper"

class Reports::NetWorthTest < ActiveSupport::TestCase
  test "adds opening balances to every movement up to each month end" do
    series = Reports::NetWorth.new(users(:ayesha), months: 2).series

    # Opening: 150,000 + 8,500 - 25,000 = 133,500. This month: +250,000 - 65,000 - 4,350.
    assert_equal 133_500.0, series[(Date.current << 1).strftime("%b %Y")]
    assert_equal 314_150.0, series[Date.current.strftime("%b %Y")]
  end

  test "converts other currencies with the user's rates" do
    accounts(:ayesha_card).update!(currency: "USD", opening_balance_cents: -10_000) # -$100.00 at 278.50
    report = Reports::NetWorth.new(users(:ayesha), months: 1)

    assert_not report.other_currencies?
    assert_equal 339_150.0 - 27_850.0, report.series.values.last
  end

  test "leaves out currencies without a rate" do
    accounts(:ayesha_card).update!(currency: "EUR")
    report = Reports::NetWorth.new(users(:ayesha), months: 1)

    assert_equal [ "EUR" ], report.excluded_currencies
    assert_equal 339_150.0, report.series.values.last
  end

  test "runs a fixed number of queries however many months are shown" do
    user = users(:ayesha)
    assert_operator count_queries { Reports::NetWorth.new(user, months: 24).series }, :<=, 6
  end
end

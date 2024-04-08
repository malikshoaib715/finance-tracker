require "test_helper"

class Reports::NetWorthTest < ActiveSupport::TestCase
  test "adds opening balances to every movement up to each month end" do
    series = Reports::NetWorth.new(users(:ayesha), months: 2).series

    # Opening: 150,000 + 8,500 - 25,000 = 133,500. This month: +250,000 - 65,000 - 4,350.
    assert_equal 133_500.0, series[(Date.current << 1).strftime("%b %Y")]
    assert_equal 314_150.0, series[Date.current.strftime("%b %Y")]
  end

  test "leaves out accounts in other currencies" do
    accounts(:ayesha_card).update!(currency: "USD")
    report = Reports::NetWorth.new(users(:ayesha), months: 1)

    assert report.other_currencies?
    assert_equal 339_150.0, report.series.values.last
  end

  test "runs a fixed number of queries however many months are shown" do
    user = users(:ayesha)
    assert_equal 3, count_queries { Reports::NetWorth.new(user, months: 24).series }
  end
end

require "test_helper"

class Reports::MonthlyCashFlowTest < ActiveSupport::TestCase
  test "sums income and expenses per month, filling empty months" do
    report = Reports::MonthlyCashFlow.new(users(:ayesha), months: 3)
    this_month = Date.current.strftime("%b %Y")

    assert_equal 3, report.income.size
    assert_equal 250_000.0, report.income[this_month]
    assert_equal 69_350.0, report.expense[this_month]
    assert_equal 180_650.0, report.net[this_month]
    assert_equal 0, report.income[(Date.current << 1).strftime("%b %Y")]
  end

  test "only counts the user's own transactions" do
    report = Reports::MonthlyCashFlow.new(users(:bilal), months: 1)
    assert_equal 1_200.0, report.expense.values.sum
  end
end

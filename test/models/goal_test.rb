require "test_helper"

class GoalTest < ActiveSupport::TestCase
  test "manual goals use the saved amount" do
    goal = goals(:umrah)
    assert_equal 15_000_000, goal.progress_cents
    assert_equal 0.25, goal.ratio
    assert_not goal.reached?
  end

  test "linked goals follow the account balance" do
    goal = goals(:emergency_fund)
    assert_equal accounts(:ayesha_cash).balance_cents, goal.progress_cents
    assert goal.reached?
    assert_nil goal.monthly_needed_cents
  end

  test "works out the monthly amount needed by the target date" do
    # 450,000 left over 10 months
    assert_equal 4_500_000, goals(:umrah).monthly_needed_cents
  end

  test "account must belong to the user" do
    assert_not users(:ayesha).goals.build(name: "x", target: "10", account: accounts(:bilal_bank)).valid?
  end
end

require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  test "tracks spending against the limit for its month" do
    budget = budgets(:ayesha_groceries)
    assert_equal 435_000, budget.spent_cents
    assert_equal 65_000, budget.remaining_cents
    assert_equal :warning, budget.status

    assert_equal :over, budgets(:ayesha_rent).status
  end

  test "normalises the month to its first day" do
    budget = users(:ayesha).budgets.build(month: Date.new(2024, 3, 17))
    assert_equal Date.new(2024, 3, 1), budget.month
  end

  test "one budget per category per month" do
    duplicate = users(:ayesha).budgets.build(category: categories(:ayesha_groceries), month: Date.current, amount: "100")
    assert_not duplicate.valid?
  end

  test "only expense categories of the same user" do
    assert_not users(:ayesha).budgets.build(category: categories(:ayesha_salary), month: Date.current, amount: "100").valid?
    assert_not users(:ayesha).budgets.build(category: categories(:bilal_groceries), month: Date.current, amount: "100").valid?
  end

  test "with_spending matches the per-budget sum in one query" do
    user = users(:ayesha)
    budgets = nil
    queries = count_queries { budgets = user.budgets.with_spending.to_a.each(&:spent_cents) }

    assert_equal 1, queries
    budgets.each { |budget| assert_equal Budget.find(budget.id).spent_cents, budget.spent_cents }
  end

  test "copies last month's budgets without overwriting existing ones" do
    user = users(:ayesha)
    next_month = Date.current.next_month
    user.budgets.create!(category: categories(:ayesha_rent), month: next_month, amount: "70000")

    copied = Budget.copy_previous_month(user, next_month)

    assert_equal [ categories(:ayesha_groceries) ], copied.map(&:category)
    assert_equal 500_000, copied.first.amount_cents
    assert_equal 7_000_000, user.budgets.for_month(next_month).find_by(category: categories(:ayesha_rent)).amount_cents
  end
end

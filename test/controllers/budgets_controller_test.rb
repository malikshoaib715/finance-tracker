require "test_helper"

class BudgetsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "shows this month's budgets with progress" do
    get budgets_url
    assert_response :success
    assert_select "##{ActionView::RecordIdentifier.dom_id(budgets(:ayesha_rent))}", text: /Over by Rs 5,000.00/
    assert_select "##{ActionView::RecordIdentifier.dom_id(budgets(:ayesha_groceries))}", text: /Rs 650.00 left/
  end

  test "another month can be empty" do
    get budgets_url(month: "2020-01")
    assert_select "p", /No budgets for January 2020/
  end

  test "creates, updates and removes a budget" do
    assert_difference "Budget.count" do
      post budgets_url, params: { budget: { category_id: categories(:ayesha_groceries).id, amount: "6000", month: "2024-03-01" } }
    end
    budget = Budget.last
    assert_redirected_to budgets_url(month: "2024-03")

    patch budget_url(budget), params: { budget: { amount: "7500" } }
    assert_equal 750_000, budget.reload.amount_cents

    assert_difference "Budget.count", -1 do
      delete budget_url(budget)
    end
  end
end

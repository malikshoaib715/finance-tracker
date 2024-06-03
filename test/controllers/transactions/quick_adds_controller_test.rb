require "test_helper"

class Transactions::QuickAddsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "adds today's expense and lets rules pick the category" do
    assert_difference "Transaction.count" do
      post quick_add_url, params: { quick_add: { amount: "1,250", description: "Imtiaz top-up", account_id: accounts(:ayesha_cash).id } }
    end
    assert_redirected_to dashboard_url
    assert_equal "Added Imtiaz top-up (Groceries).", flash[:notice]
    assert_equal Date.current, Transaction.last.occurred_on
  end

  test "reports validation errors" do
    post quick_add_url, params: { quick_add: { amount: "0", description: "", account_id: accounts(:ayesha_cash).id } }
    assert_redirected_to dashboard_url
    assert_match "Description can't be blank", flash[:alert]
  end
end

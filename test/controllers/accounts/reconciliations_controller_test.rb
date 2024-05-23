require "test_helper"

class Accounts::ReconciliationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "reconciles an account" do
    get new_account_reconciliation_url(accounts(:ayesha_cash))
    assert_response :success

    post account_reconciliation_url(accounts(:ayesha_cash)), params: { reconciliation: { actual_balance: "25000" } }
    assert_redirected_to account_url(accounts(:ayesha_cash))
    assert_equal "Recorded an adjustment of Rs 850.00.", flash[:notice]
  end
end

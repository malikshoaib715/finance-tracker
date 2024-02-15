require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "lists only the signed in user's active accounts" do
    get accounts_url
    assert_response :success
    assert_select "##{ActionView::RecordIdentifier.dom_id(accounts(:ayesha_bank))}"
    assert_select "##{ActionView::RecordIdentifier.dom_id(accounts(:bilal_bank))}", count: 0
  end

  test "creates an account from a major-unit balance" do
    assert_difference "Account.count" do
      post accounts_url, params: { account: { name: "JazzCash", kind: "wallet", currency: "PKR", opening_balance: "1,250.75" } }
    end
    assert_redirected_to accounts_url
    assert_equal 125_075, Account.last.opening_balance_cents
  end

  test "re-renders the form when invalid" do
    post accounts_url, params: { account: { name: "", kind: "bank", currency: "PKR" } }
    assert_response :unprocessable_entity
  end

  test "updates an account" do
    patch account_url(accounts(:ayesha_cash)), params: { account: { name: "Pocket cash" } }
    assert_redirected_to accounts_url
    assert_equal "Pocket cash", accounts(:ayesha_cash).reload.name
  end

  test "cannot edit someone else's account" do
    get edit_account_url(accounts(:bilal_bank))
    assert_response :not_found
  end
end

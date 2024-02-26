require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "lists the user's transactions" do
    get transactions_url
    assert_response :success
    assert_select "##{ActionView::RecordIdentifier.dom_id(transactions(:rent))}"
    assert_select "##{ActionView::RecordIdentifier.dom_id(transactions(:bilal_groceries))}", count: 0
  end

  test "records an expense" do
    assert_difference "Transaction.count" do
      post transactions_url, params: { transaction: {
        kind: "expense", amount: "2,300", occurred_on: Date.current, description: "Electricity bill",
        account_id: accounts(:ayesha_bank).id, category_id: categories(:ayesha_rent).id
      } }
    end
    assert_redirected_to transactions_url
    assert_equal 230_000, Transaction.last.amount_cents
  end

  test "can't record into someone else's account" do
    assert_no_difference "Transaction.count" do
      post transactions_url, params: { transaction: {
        kind: "expense", amount: "10", occurred_on: Date.current, description: "Sneaky",
        account_id: accounts(:bilal_bank).id
      } }
    end
    assert_response :unprocessable_entity
  end

  test "updates and deletes a transaction" do
    patch transaction_url(transactions(:groceries)), params: { transaction: { description: "Imtiaz monthly shop" } }
    assert_equal "Imtiaz monthly shop", transactions(:groceries).reload.description

    assert_difference "Transaction.count", -1 do
      delete transaction_url(transactions(:groceries))
    end
  end
end

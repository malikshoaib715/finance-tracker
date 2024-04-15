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

  test "filters the list" do
    get transactions_url, params: { filter: { q: "rent" } }
    assert_select "##{ActionView::RecordIdentifier.dom_id(transactions(:rent))}"
    assert_select "##{ActionView::RecordIdentifier.dom_id(transactions(:groceries))}", count: 0
    assert_select "a", "Clear"
  end

  test "exports the filtered transactions as CSV" do
    get export_transactions_url(filter: { kind: "income" })
    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_match "February salary", response.body
    assert_no_match "Flat rent", response.body
  end

  test "repeating a transaction pre-fills the form with today's date" do
    get new_transaction_url(repeat: transactions(:rent))
    assert_select "input#transaction_description[value=?]", "Flat rent"
    assert_select "input#transaction_amount[value=?]", "65000.0"
    assert_select "input#transaction_occurred_on[value=?]", Date.current.iso8601
  end

  test "can't repeat someone else's transaction" do
    get new_transaction_url(repeat: transactions(:bilal_groceries))
    assert_select "input#transaction_description:not([value])"
  end

  test "saves tags from the form and shows them in the list" do
    patch transaction_url(transactions(:rent)), params: { transaction: { tag_list: "housing, family" } }
    assert_equal %w[family housing], transactions(:rent).reload.tags.map(&:name).sort

    get transactions_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(transactions(:rent))}", text: /#housing/
  end

  test "warns when an expense takes a category over budget" do
    post transactions_url, params: { transaction: {
      kind: "expense", amount: "1,000", occurred_on: Date.current, description: "Big shop",
      account_id: accounts(:ayesha_cash).id, category_id: categories(:ayesha_groceries).id
    } }
    assert_equal "You're over your Groceries budget by Rs 350.00.", flash[:alert]
  end

  test "no warning without a budget" do
    post transactions_url, params: { transaction: {
      kind: "expense", amount: "10", occurred_on: Date.current, description: "Tea",
      account_id: accounts(:ayesha_cash).id
    } }
    assert_nil flash[:alert]
  end
end

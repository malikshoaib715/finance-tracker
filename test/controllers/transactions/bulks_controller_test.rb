require "test_helper"

class Transactions::BulksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "sets the category on matching transactions only" do
    ids = [ transactions(:rent), transactions(:groceries), transactions(:salary) ].map(&:id)
    patch transactions_bulk_url, params: { transaction_ids: ids, category_id: categories(:ayesha_groceries).id }

    assert_equal "Updated 2 transactions. 1 skipped: Groceries is an expense category.", flash[:notice]
    assert_equal categories(:ayesha_groceries), transactions(:rent).reload.category
    assert_equal categories(:ayesha_salary), transactions(:salary).reload.category
  end

  test "clears the category" do
    patch transactions_bulk_url, params: { transaction_ids: [ transactions(:rent).id ], category_id: "" }
    assert_nil transactions(:rent).reload.category
  end

  test "deletes several transactions, ignoring other users' ids" do
    assert_difference "Transaction.count", -2 do
      delete transactions_bulk_url, params: { transaction_ids: [ transactions(:rent), transactions(:groceries), transactions(:bilal_groceries) ].map(&:id) }
    end
    assert transactions(:bilal_groceries).reload.persisted?
  end

  test "needs a selection" do
    delete transactions_bulk_url
    assert_equal "Select some transactions first.", flash[:alert]
  end
end

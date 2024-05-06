require "test_helper"

class RecurringTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "lists recurring items, paused ones included" do
    get recurring_transactions_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(recurring_transactions(:rent))}", text: /Monthly/
    assert_select "##{ActionView::RecordIdentifier.dom_id(recurring_transactions(:netflix))}", text: /paused/
  end

  test "creates, pauses and deletes an item" do
    assert_difference "RecurringTransaction.count" do
      post recurring_transactions_url, params: { recurring_transaction: {
        kind: "expense", amount: "3,200", description: "PTCL internet", frequency: "monthly",
        next_on: Date.current.next_month, account_id: accounts(:ayesha_bank).id
      } }
    end
    item = RecurringTransaction.last
    assert_equal 320_000, item.amount_cents

    patch recurring_transaction_url(item), params: { recurring_transaction: { active: "0" } }
    assert_not item.reload.active?

    assert_difference "RecurringTransaction.count", -1 do
      delete recurring_transaction_url(item)
    end
  end
end

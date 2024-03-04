require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "records a transfer" do
    assert_difference "Transfer.count" do
      post transfers_url, params: { transfer: {
        from_account_id: accounts(:ayesha_bank).id, to_account_id: accounts(:ayesha_cash).id,
        amount: "5,000", occurred_on: Date.current
      } }
    end
    assert_redirected_to transactions_url
    assert_equal 500_000, Transfer.last.amount_cents
  end

  test "rejects a transfer to the same account" do
    post transfers_url, params: { transfer: {
      from_account_id: accounts(:ayesha_bank).id, to_account_id: accounts(:ayesha_bank).id,
      amount: "10", occurred_on: Date.current
    } }
    assert_response :unprocessable_entity
  end

  test "transfers appear in the transactions list" do
    get transactions_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(transfers(:atm_withdrawal))}", text: /ATM withdrawal/
  end

  test "updates and deletes a transfer" do
    patch transfer_url(transfers(:atm_withdrawal)), params: { transfer: { amount: "25000" } }
    assert_equal 2_500_000, transfers(:atm_withdrawal).reload.amount_cents

    assert_difference "Transfer.count", -1 do
      delete transfer_url(transfers(:atm_withdrawal))
    end
  end
end

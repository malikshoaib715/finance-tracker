require "test_helper"

class Transactions::ReceiptsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "uploads receipts and keeps existing ones on later edits" do
    transaction = transactions(:rent)

    patch transaction_url(transaction), params: { transaction: {
      receipts: [ fixture_file_upload("receipt.pdf", "application/pdf") ]
    } }
    assert_equal 1, transaction.reload.receipts.count

    patch transaction_url(transaction), params: { transaction: {
      receipts: [ transaction.receipts.first.signed_id, fixture_file_upload("receipt.pdf", "application/pdf") ]
    } }
    assert_equal 2, transaction.reload.receipts.count
  end

  test "removes a receipt" do
    transaction = transactions(:rent)
    transaction.receipts.attach(io: file_fixture("receipt.pdf").open, filename: "receipt.pdf", content_type: "application/pdf")

    delete transaction_receipt_url(transaction, transaction.receipts.first)
    assert_redirected_to edit_transaction_url(transaction)
    assert_not transaction.reload.receipts.attached?
  end

  test "can't remove receipts from someone else's transaction" do
    other = transactions(:bilal_groceries)
    other.receipts.attach(io: file_fixture("receipt.pdf").open, filename: "receipt.pdf", content_type: "application/pdf")

    delete transaction_receipt_url(other, other.receipts.first)
    assert_response :not_found
  end
end

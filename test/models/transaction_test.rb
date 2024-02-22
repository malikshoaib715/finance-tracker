require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  def build(attrs = {})
    users(:ayesha).transactions.build({
      account: accounts(:ayesha_bank), category: categories(:ayesha_groceries),
      kind: "expense", amount: "1,500.25", occurred_on: Date.current, description: "Test"
    }.merge(attrs))
  end

  test "stores amounts as positive minor units" do
    transaction = build(amount: "-1,500.25")
    assert_equal 150_025, transaction.amount_cents
  end

  test "signed amount follows the kind" do
    assert_equal(-6_500_000, transactions(:rent).signed_amount_cents)
    assert_equal 25_000_000, transactions(:salary).signed_amount_cents
  end

  test "rejects zero and non-numeric amounts" do
    assert_not build(amount: "0").valid?
    assert_not build(amount: "abc").valid?
  end

  test "category must match the kind" do
    transaction = build(kind: "income", category: categories(:ayesha_groceries))
    assert_not transaction.valid?
    assert_includes transaction.errors[:category], "is for expenses, not incomes"
  end

  test "account and category must belong to the same user" do
    transaction = build(account: accounts(:bilal_bank), category: categories(:bilal_groceries))
    assert_not transaction.valid?
    assert transaction.errors[:account].any?
    assert transaction.errors[:category].any?
  end

  test "account balance includes its transactions" do
    # 150,000.00 opening + 250,000.00 salary - 65,000.00 rent
    assert_equal 33_500_000, accounts(:ayesha_bank).balance_cents
  end

  test "accounts with transactions can't be deleted" do
    assert_not accounts(:ayesha_bank).destroy
  end
end

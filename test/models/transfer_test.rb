require "test_helper"

class TransferTest < ActiveSupport::TestCase
  def build(attrs = {})
    users(:ayesha).transfers.build({
      from_account: accounts(:ayesha_bank), to_account: accounts(:ayesha_cash),
      amount: "500", occurred_on: Date.current
    }.merge(attrs))
  end

  test "moves money between accounts" do
    # bank: 150,000 + 250,000 - 65,000 - 20,000 transfer out
    assert_equal 31_500_000, accounts(:ayesha_bank).balance_cents
    # cash: 8,500 - 4,350 + 20,000 transfer in
    assert_equal 2_415_000, accounts(:ayesha_cash).balance_cents
  end

  test "accounts must differ" do
    transfer = build(to_account: accounts(:ayesha_bank))
    assert_not transfer.valid?
    assert transfer.errors[:to_account].any?
  end

  test "accounts must belong to the user" do
    assert_not build(to_account: accounts(:bilal_bank)).valid?
  end

  test "accounts must share a currency" do
    accounts(:ayesha_cash).update!(currency: "USD")
    transfer = build
    assert_not transfer.valid?
    assert_includes transfer.errors[:to_account], "must use the same currency (PKR)"
  end

  test "defaults the title from the destination" do
    assert_equal "Transfer to Wallet cash", build.title
    assert_equal "ATM withdrawal", transfers(:atm_withdrawal).title
  end
end

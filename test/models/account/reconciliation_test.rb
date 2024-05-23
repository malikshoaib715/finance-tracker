require "test_helper"

class Account::ReconciliationTest < ActiveSupport::TestCase
  test "records the difference as an adjustment" do
    account = accounts(:ayesha_cash) # tracked: 24,150.00
    adjustment = Account::Reconciliation.new(account:, actual_balance: "23,900").save

    assert_equal [ "expense", 25_000 ], [ adjustment.kind, adjustment.amount_cents ]
    assert_equal 2_390_000, account.reload.balance_cents
  end

  test "does nothing when the balance matches" do
    account = accounts(:ayesha_cash)
    assert_nil Account::Reconciliation.new(account:, actual_balance: "24150.00").save
  end

  test "needs a number" do
    assert_equal false, Account::Reconciliation.new(account: accounts(:ayesha_cash), actual_balance: "lots").save
  end
end

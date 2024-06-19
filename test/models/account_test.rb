require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "names are unique per user, ignoring case" do
    duplicate = users(:ayesha).accounts.build(name: "meezan current", currency: "PKR")
    assert_not duplicate.valid?

    other_user = users(:bilal).accounts.build(name: "Meezan Current", currency: "PKR")
    assert other_user.valid?
  end

  test "rejects unknown kinds and currencies" do
    account = users(:ayesha).accounts.build(name: "Odd", kind: "crypto", currency: "XYZ")
    assert_not account.valid?
    assert account.errors[:kind].any?
    assert account.errors[:currency].any?
  end

  test "archiving hides the account from active" do
    account = accounts(:ayesha_cash)
    account.archive!
    assert account.archived?
    assert_not_includes users(:ayesha).accounts.active, account

    account.unarchive!
    assert_includes users(:ayesha).accounts.active, account
  end

  test "deleting a user removes their accounts" do
    assert_difference({ "Account.count" => -3, "Transaction.count" => -3 }) do
      users(:ayesha).destroy
    end
  end

  test "ledger lists movements oldest first with a running balance" do
    ledger = accounts(:ayesha_bank).ledger

    assert_equal [ "February salary", "Flat rent", "To Wallet cash" ], ledger.map(&:title)
    assert_equal [ 25_000_000, -6_500_000, -2_000_000 ], ledger.map(&:amount_cents)
    assert_equal accounts(:ayesha_bank).balance_cents, ledger.last.balance_cents
  end

  test "with_balances matches the per-account calculation" do
    users(:ayesha).accounts.with_balances.each do |account|
      assert_equal account.reload.balance_cents, users(:ayesha).accounts.with_balances.find(account.id).balance_cents
    end
  end

  test "with_balances loads all balances in a single query" do
    user = users(:ayesha)
    queries = count_queries { user.accounts.with_balances.map(&:balance_cents) }
    assert_equal 1, queries
  end

  test "new accounts go to the end and can be moved" do
    account = users(:ayesha).accounts.create!(name: "JazzCash", kind: "wallet", currency: "PKR")
    assert_equal 4, account.position

    account.move(-1)
    assert_equal [ "HBL Credit Card", "Meezan Current", "JazzCash", "Wallet cash" ], users(:ayesha).accounts.ordered.map(&:name)

    accounts(:ayesha_card).reload.move(-1) # already first
    assert_equal "HBL Credit Card", users(:ayesha).accounts.ordered.first.name
  end
end

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
    assert_difference "Account.count", -3 do
      users(:ayesha).destroy
    end
  end
end

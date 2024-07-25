require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires a unique email" do
    user = User.new(name: "Sara", email: users(:ayesha).email, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires a password of at least 6 characters" do
    user = User.new(name: "Sara", email: "new@example.com", password: "short")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "requires a name and tidies whitespace" do
    assert_not User.new(email: "x@example.com", password: "password123").valid?

    user = User.new(name: "  Sara   Malik ", email: "x@example.com", password: "password123")
    assert_equal "Sara Malik", user.name
    assert_equal "SM", user.initials
    assert_equal "Sara", user.first_name
  end

  test "finance cache version changes with new activity" do
    user = users(:ayesha)
    before = user.finance_cache_version

    travel 1.second do
      transactions(:rent).touch
    end
    assert_not_equal before, user.finance_cache_version
  end

  test "preferred account falls back to the first one" do
    user = users(:ayesha)
    assert_equal "HBL Credit Card", user.preferred_account.name
    user.update!(default_account: accounts(:ayesha_cash))
    assert_equal accounts(:ayesha_cash), user.preferred_account
  end

  test "default account must be the user's own" do
    user = users(:ayesha)
    user.default_account = accounts(:bilal_bank)
    assert_not user.valid?
  end
end

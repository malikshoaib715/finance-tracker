require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires a unique email" do
    user = User.new(email: users(:ayesha).email, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires a password of at least 6 characters" do
    user = User.new(email: "new@example.com", password: "short")
    assert_not user.valid?
    assert user.errors[:password].any?
  end
end

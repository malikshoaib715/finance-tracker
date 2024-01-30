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
end

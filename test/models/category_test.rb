require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "names are unique per user and kind" do
    assert_not users(:ayesha).categories.build(name: "groceries", kind: "expense").valid?
    assert users(:ayesha).categories.build(name: "Groceries", kind: "income").valid?
  end

  test "colour must come from the palette" do
    category = users(:ayesha).categories.build(name: "Gifts", color: "neon")
    assert_not category.valid?
  end

  test "new users get a starter set of categories" do
    user = User.create!(name: "Zara Hussain", email: "zara@example.com", password: "password123")

    assert_equal Category::DEFAULTS[:expense].size, user.categories.expense.count
    assert_equal Category::DEFAULTS[:income].size, user.categories.income.count
  end

  test "creating defaults twice doesn't duplicate them" do
    user = users(:bilal)
    Category.create_defaults_for(user)
    assert_no_difference "Category.count" do
      Category.create_defaults_for(user)
    end
  end
end

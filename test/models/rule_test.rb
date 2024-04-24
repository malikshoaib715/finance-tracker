require "test_helper"

class RuleTest < ActiveSupport::TestCase
  test "finds a category by case-insensitive match" do
    assert_equal categories(:ayesha_groceries), Rule.category_for(users(:ayesha), "POS PURCHASE IMTIAZ SUPERMARKET", :expense)
    assert_nil Rule.category_for(users(:ayesha), "Careem ride", :expense)
  end

  test "only matches categories of the same kind" do
    assert_equal categories(:ayesha_salary), Rule.category_for(users(:ayesha), "Salary April", :income)
    assert_nil Rule.category_for(users(:ayesha), "Salary advance repayment", :expense)
  end

  test "prefers the longest matching pattern" do
    users(:ayesha).rules.create!(pattern: "imtiaz pharmacy", category: categories(:ayesha_rent))
    assert_equal categories(:ayesha_rent), Rule.category_for(users(:ayesha), "IMTIAZ PHARMACY GULBERG", :expense)
  end

  test "patterns are unique per user and need a category of theirs" do
    assert_not users(:ayesha).rules.build(pattern: "Imtiaz", category: categories(:ayesha_rent)).valid?
    assert_not users(:ayesha).rules.build(pattern: "al-fatah", category: categories(:bilal_groceries)).valid?
  end
end

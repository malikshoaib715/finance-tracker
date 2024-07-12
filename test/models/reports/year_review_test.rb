require "test_helper"

class Reports::YearReviewTest < ActiveSupport::TestCase
  test "totals the year and works out the savings rate" do
    review = Reports::YearReview.new(users(:ayesha))
    assert_equal 25_000_000, review.income_cents
    assert_equal 6_935_000, review.expense_cents
    assert_in_delta 0.7226, review.savings_rate, 0.0001
    assert_equal "Rent", review.top_categories.keys.first
  end

  test "no income means no savings rate" do
    assert_nil Reports::YearReview.new(users(:bilal)).savings_rate
  end
end

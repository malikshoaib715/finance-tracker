require "test_helper"

class MoneyHelperTest < ActionView::TestCase
  def current_user = nil

  test "formats minor units with the currency symbol" do
    assert_equal "Rs 1,234.50", money(123_450, "PKR")
    assert_equal "$5.00", money(500, "USD")
    assert_equal "€0.99", money(99, "EUR")
  end

  test "puts the sign before the symbol" do
    assert_equal "-$5.00", money(-500, "USD")
  end

  test "falls back to the code for unknown currencies" do
    assert_equal "JPY 10.00", money(1000, "JPY")
  end

  test "money_tag colours by sign" do
    assert_includes money_tag(-100, "USD"), "text-rose-600"
    assert_includes money_tag(100, "USD"), "text-emerald-700"
  end
end

require "test_helper"

class MoneyHelperTest < ActionView::TestCase
  attr_accessor :current_user

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

  test "groups digits in lakh and crore when the user prefers it" do
    self.current_user = User.new(number_format: "south_asian")
    assert_equal "Rs 1,50,000.00", money(15_000_000, "PKR")
    assert_equal "Rs 1,23,45,678.90", money(1_234_567_890, "PKR")
    assert_equal "Rs 999.00", money(99_900, "PKR")
    assert_equal "-Rs 12,500.50", money(-1_250_050, "PKR")
  end
end

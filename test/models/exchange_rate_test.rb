require "test_helper"

class ExchangeRateTest < ActiveSupport::TestCase
  test "converts into the user's default currency" do
    user = users(:ayesha)
    assert_equal 27_850, ExchangeRate.convert(user, 100, "USD")
    assert_equal 500, ExchangeRate.convert(user, 500, "PKR")
    assert_nil ExchangeRate.convert(user, 100, "EUR")
  end

  test "one rate per currency, never for the default currency" do
    assert_not users(:ayesha).exchange_rates.build(currency: "USD", rate: 280).valid?
    assert_not users(:ayesha).exchange_rates.build(currency: "PKR", rate: 1).valid?
    assert_not users(:ayesha).exchange_rates.build(currency: "EUR", rate: 0).valid?
  end
end

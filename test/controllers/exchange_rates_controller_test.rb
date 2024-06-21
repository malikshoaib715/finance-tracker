require "test_helper"

class ExchangeRatesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "points out currencies without a rate" do
    accounts(:ayesha_cash).update!(currency: "AED")
    get exchange_rates_url
    assert_select "p", /accounts in AED without a rate/
  end

  test "adds or updates a rate" do
    post exchange_rates_url, params: { exchange_rate: { currency: "USD", rate: "280.25" } }
    assert_equal BigDecimal("280.25"), exchange_rates(:ayesha_usd).reload.rate

    assert_difference "ExchangeRate.count" do
      post exchange_rates_url, params: { exchange_rate: { currency: "AED", rate: "75.8" } }
    end
  end

  test "removes a rate" do
    assert_difference "ExchangeRate.count", -1 do
      delete exchange_rate_url(exchange_rates(:ayesha_usd))
    end
  end
end

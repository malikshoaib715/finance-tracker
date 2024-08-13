require "test_helper"

class Api::SummaryTest < ActionDispatch::IntegrationTest
  test "returns this month's numbers and budgets" do
    get api_v1_summary_url, headers: { "Authorization" => "Bearer ft_ayesha_test_token" }
    body = response.parsed_body

    assert_equal [ 25_000_000, 6_935_000, 31_415_000 ], body.values_at("income_cents", "expense_cents", "net_worth_cents")
    rent = body["budgets"].find { _1["category"] == "Rent" }
    assert_equal [ 6_000_000, 6_500_000, "over" ], rent.values_at("amount_cents", "spent_cents", "status")
  end
end

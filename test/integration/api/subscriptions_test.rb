require "test_helper"

class Api::SubscriptionsTest < ActionDispatch::IntegrationTest
  test "lists the user's subscriptions with alerts" do
    get api_v1_subscriptions_url, headers: { "Authorization" => "Bearer ft_ayesha_test_token" }
    body = response.parsed_body

    assert_equal %w[DramaBox iCloud+], body["subscriptions"].map { _1["service"] }
    assert_equal 476_667, body["subscriptions"].first["monthly_cents"]
    assert_equal "warning", body["alerts"].sole["level"]
  end
end

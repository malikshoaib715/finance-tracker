require "test_helper"

class Api::AuthenticationTest < ActionDispatch::IntegrationTest
  test "rejects requests without a valid token" do
    get api_v1_me_url
    assert_response :unauthorized
    assert_equal "Missing or invalid API token", response.parsed_body.dig("error", "message")

    get api_v1_me_url, headers: { "Authorization" => "Bearer ft_nope" }
    assert_response :unauthorized
  end

  test "returns the token's user" do
    get api_v1_me_url, headers: { "Authorization" => "Bearer ft_ayesha_test_token" }
    assert_response :success
    assert_equal "ayesha@example.com", response.parsed_body["email"]
    assert api_tokens(:ayesha_phone).reload.last_used_at
  end
end

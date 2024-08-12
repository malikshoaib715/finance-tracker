require "test_helper"

class Api::SessionsTest < ActionDispatch::IntegrationTest
  test "signs in with email and password and gets a device token" do
    assert_difference "ApiToken.count" do
      post api_v1_session_url, as: :json, params: { email: "Ayesha@Example.com ", password: "password123", device_name: "Pixel 8" }
    end
    assert_response :created
    token = response.parsed_body["token"]

    get api_v1_me_url, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success

    assert_difference "ApiToken.count", -1 do
      delete api_v1_session_url, headers: { "Authorization" => "Bearer #{token}" }
    end
  end

  test "rejects a wrong password and counts it toward the lock" do
    post api_v1_session_url, as: :json, params: { email: "ayesha@example.com", password: "nope" }
    assert_response :unauthorized
    assert_equal 1, users(:ayesha).reload.failed_attempts
  end

  test "unconfirmed users past the grace period can't sign in" do
    user = users(:bilal)
    user.update_columns(confirmed_at: nil, confirmation_sent_at: 1.week.ago, created_at: 1.week.ago)
    post api_v1_session_url, as: :json, params: { email: user.email, password: "password123" }
    assert_response :unauthorized
  end
end

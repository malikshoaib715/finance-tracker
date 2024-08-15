require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  teardown { Rack::Attack.enabled = false }

  test "throttles repeated sign-in attempts for one email" do
    5.times { post user_session_path, params: { user: { email: "ayesha@example.com", password: "wrong" } } }
    assert_not_equal 429, response.status

    post user_session_path, params: { user: { email: "ayesha@example.com", password: "wrong" } }
    assert_equal 429, response.status
    assert_match "Too many attempts", response.body
  end

  test "throttles a runaway API client per token" do
    300.times { get api_v1_me_url, headers: { "Authorization" => "Bearer ft_ayesha_test_token" } }
    assert_response :success

    get api_v1_me_url, headers: { "Authorization" => "Bearer ft_ayesha_test_token" }
    assert_equal 429, response.status
  end
end

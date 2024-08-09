require "test_helper"

class Users::ApiTokensControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "creates a token and shows it once" do
    assert_difference "ApiToken.count" do
      post api_tokens_url, params: { api_token: { name: "Laptop" } }
    end
    follow_redirect!
    assert_select "code.select-all", /\Aft_/

    get api_tokens_url
    assert_select "code.select-all", count: 0
  end

  test "revokes only the user's own tokens" do
    assert_difference "ApiToken.count", -1 do
      delete api_token_url(api_tokens(:ayesha_phone))
    end
    delete api_token_url(api_tokens(:bilal_phone))
    assert_response :not_found
  end
end

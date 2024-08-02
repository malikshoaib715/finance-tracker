require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  test "stores only a digest and authenticates with the plain token" do
    token = users(:ayesha).api_tokens.create!(name: "Laptop script")

    assert token.plain_token.start_with?("ft_")
    assert_not_equal token.plain_token, token.token_digest
    assert_equal token, ApiToken.authenticate(token.plain_token)
    assert_nil ApiToken.authenticate("ft_wrong")
    assert_nil ApiToken.authenticate(nil)
  end
end

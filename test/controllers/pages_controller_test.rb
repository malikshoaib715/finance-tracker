require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get root_url
    assert_response :success
    assert_select "h1", "Know where your money goes"
    assert_select "a", "Sign in"
  end

  test "navbar shows the account menu when signed in" do
    sign_in users(:ayesha)
    get root_url
    assert_select "button", "Sign out"
    assert_select "a", "Account settings"
  end
end

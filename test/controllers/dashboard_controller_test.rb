require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to sign in" do
    get dashboard_url
    assert_redirected_to new_user_session_url
  end

  test "shows the dashboard to signed in users" do
    sign_in users(:ayesha)
    get dashboard_url
    assert_response :success
    assert_select "h1", "Dashboard"
  end

  test "root goes to the dashboard once signed in" do
    sign_in users(:ayesha)
    get root_url
    assert_select "h1", "Dashboard"
  end
end

require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "shows the reports page" do
    sign_in users(:ayesha)
    get reports_url
    assert_response :success
    assert_select "h2", "Income vs expenses"
  end
end

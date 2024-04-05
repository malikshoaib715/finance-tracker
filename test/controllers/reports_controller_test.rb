require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "shows the reports page" do
    sign_in users(:ayesha)
    get reports_url
    assert_response :success
    assert_select "h2", "Income vs expenses"
  end

  test "breakdown can show an earlier month" do
    sign_in users(:ayesha)
    get reports_url(month: "2023-12")
    assert_select "p", /December 2023 compared with November/
  end

  test "future and invalid months fall back to this month" do
    sign_in users(:ayesha)
    get reports_url(month: "2999-01")
    assert_select "p", /#{Date.current.strftime("%B %Y")} compared with/
    get reports_url(month: "nope")
    assert_response :success
  end
end

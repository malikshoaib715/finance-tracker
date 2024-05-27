require "test_helper"

class Users::DataExportsControllerTest < ActionDispatch::IntegrationTest
  test "downloads the signed in user's data as JSON" do
    sign_in users(:ayesha)
    get data_export_url

    assert_response :success
    assert_equal "application/json", response.media_type
    assert_match "attachment", response.headers["Content-Disposition"]
    assert_equal "Ayesha Khan", JSON.parse(response.body).dig("user", "name")
  end
end

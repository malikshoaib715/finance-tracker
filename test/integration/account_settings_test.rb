require "test_helper"

class AccountSettingsTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "updates the name with the current password" do
    patch user_registration_path, params: { user: { name: "Ayesha Siddiqui", current_password: "password123" } }
    assert_redirected_to root_path
    assert_equal "Ayesha Siddiqui", users(:ayesha).reload.name
  end

  test "rejects changes without the current password" do
    patch user_registration_path, params: { user: { name: "Someone Else", current_password: "" } }
    assert_response :unprocessable_entity
    assert_equal "Ayesha Khan", users(:ayesha).reload.name
  end
end

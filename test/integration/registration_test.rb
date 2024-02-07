require "test_helper"

class RegistrationTest < ActionDispatch::IntegrationTest
  test "signing up sends a confirmation email" do
    assert_emails 1 do
      post user_registration_path, params: { user: {
        name: "Zara Hussain", email: "zara@example.com",
        password: "password123", password_confirmation: "password123"
      } }
    end

    user = User.find_by!(email: "zara@example.com")
    assert_not user.confirmed?
    assert_match "Confirm my email", ActionMailer::Base.deliveries.last.body.encoded
  end

  test "unconfirmed users see a reminder banner" do
    user = User.create!(name: "Zara Hussain", email: "zara@example.com", password: "password123")
    sign_in user
    get dashboard_url
    assert_select "p", /Please confirm your email/
  end
end

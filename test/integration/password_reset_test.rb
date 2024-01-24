require "test_helper"

class PasswordResetTest < ActionDispatch::IntegrationTest
  test "requesting a reset sends instructions by email" do
    assert_emails 1 do
      post user_password_path, params: { user: { email: users(:ayesha).email } }
    end
    assert_redirected_to new_user_session_path

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ users(:ayesha).email ], mail.to
    assert_match "Change my password", mail.body.encoded
  end
end

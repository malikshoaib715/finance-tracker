require "test_helper"

class LockableTest < ActionDispatch::IntegrationTest
  test "locks the account after ten failed sign-ins and emails an unlock link" do
    user = users(:ayesha)

    assert_emails 1 do
      10.times { post user_session_path, params: { user: { email: user.email, password: "wrong" } } }
    end
    assert user.reload.access_locked?
    assert_match "Unlock my account", ActionMailer::Base.deliveries.last.body.encoded

    post user_session_path, params: { user: { email: user.email, password: "password123" } }
    assert_response :unprocessable_entity
  end
end

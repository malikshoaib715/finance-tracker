require "test_helper"

class MailConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:ayesha)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(
      provider: "google", uid: "123", info: { email: "ayesha@gmail.com" },
      credentials: { token: "access-1", refresh_token: "refresh-1", expires_at: 1.hour.from_now.to_i }
    )
  end

  teardown { OmniAuth.config.test_mode = false }

  test "stores the connection with encrypted tokens" do
    get google_callback_url, env: { "omniauth.auth" => OmniAuth.config.mock_auth[:google] }
    assert_redirected_to subscriptions_url

    connection = users(:ayesha).reload.mail_connection
    assert_equal "ayesha@gmail.com", connection.email
    assert_equal "refresh-1", connection.refresh_token
    raw = MailConnection.connection.select_value("SELECT refresh_token FROM mail_connections WHERE id = #{connection.id}")
    assert_not_includes raw, "refresh-1"
  end

  test "disconnecting removes the tokens and what was learned from Gmail" do
    users(:ayesha).create_mail_connection!(email: "ayesha@gmail.com", refresh_token: "r")
    learned = users(:ayesha).subscriptions.create!(service: "Spotify Premium")
    learned.events.create!(kind: "charged", occurred_on: Date.current, source: "gmail", source_ref: "g1")

    delete mail_connection_url

    assert_nil users(:ayesha).reload.mail_connection
    assert_not Subscription.exists?(learned.id)
    assert Subscription.exists?(subscriptions(:ayesha_icloud).id) # learned from forwarded mail, kept
  end
end

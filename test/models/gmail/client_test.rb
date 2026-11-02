require "test_helper"

class Gmail::ClientTest < ActiveSupport::TestCase
  def encode(text) = Base64.urlsafe_encode64(text)

  def message_json
    {
      "internalDate" => "1792500000000",
      "payload" => {
        "headers" => [
          { "name" => "From", "value" => "Apple <no_reply@email.apple.com>" },
          { "name" => "Subject", "value" => "Your receipt from Apple." },
          { "name" => "Date", "value" => "Tue, 21 Oct 2026 10:00:00 +0500" }
        ],
        "mimeType" => "multipart/alternative",
        "parts" => [
          { "mimeType" => "text/html", "body" => { "data" => encode("<p>html</p>") } },
          { "mimeType" => "text/plain", "body" => { "data" => encode("iCloud+\niCloud+ with 200 GB (Monthly)\nRs 800.00\nVisa •••• 8685") } }
        ]
      }
    }
  end

  setup do
    @connection = users(:ayesha).create_mail_connection!(email: "a@gmail.com", access_token: "old", refresh_token: "r",
                                                         expires_at: 1.minute.ago)
    @calls = []
    @transport = lambda do |method, url, headers, _body|
      @calls << [ method, url, headers["Authorization"] ]
      case url
      when /oauth2/ then [ 200, { "access_token" => "fresh", "expires_in" => 3600 } ]
      when %r{/messages\?} then [ 200, { "messages" => [ { "id" => "m1" } ] } ]
      when %r{/messages/m1} then [ 200, message_json ]
      end
    end
  end

  test "refreshes an expired token before calling Gmail" do
    client = Gmail::Client.new(@connection, transport: @transport)
    assert_equal [ "m1" ], client.message_ids("from:apple.com")
    assert_equal :post, @calls.first.first
    assert_equal "Bearer fresh", @calls.last.last
    assert_equal "fresh", @connection.reload.access_token
  end

  test "reads headers and prefers the plain-text part" do
    email = Gmail::Client.new(@connection, transport: @transport).message("m1")
    assert_equal "no_reply@email.apple.com", email.sender
    assert_match "Rs 800.00", email.text
  end

  test "the sync job turns receipts into subscriptions and records errors" do
    client = Gmail::Client.new(@connection, transport: @transport)
    GmailSyncJob.perform_now(@connection.id, client:)

    sub = users(:ayesha).subscriptions.find_by!(service: "iCloud+")
    assert_equal "8685", sub.card_last4
    assert sub.events.exists?(source: "gmail")
    assert @connection.reload.last_synced_at

    revoked = Gmail::Client.new(@connection, transport: ->(*) { [ 401, { "error" => { "message" => "invalid" } } ] })
    GmailSyncJob.perform_now(@connection.id, client: revoked)
    assert_match "Gmail returned 401", @connection.reload.last_error
  end
end

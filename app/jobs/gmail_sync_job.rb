# Reads new receipts from a connected Gmail account and updates subscriptions.
# Only known receipt senders are searched, and bodies are dropped after parsing.
class GmailSyncJob < ApplicationJob
  queue_as :default

  SENDERS = %w[
    no_reply@email.apple.com googleplay-noreply@google.com stripe.com netflix.com
    spotify.com linkedin.com youtube.com
  ].freeze

  def perform(connection_id, client: nil)
    connection = MailConnection.find_by(id: connection_id) or return
    client ||= Gmail::Client.new(connection)
    since = (connection.last_synced_at || 13.months.ago).to_date
    query = "{#{SENDERS.map { "from:#{_1}" }.join(" ")}} after:#{since.strftime('%Y/%m/%d')}"

    facts = client.message_ids(query).flat_map { Receipts::Parser.parse(client.message(_1)) }
    Subscriptions::Detector.new(connection.user, source: "gmail").record(facts)
    connection.update!(last_synced_at: Time.current, last_error: nil)
  rescue Gmail::Client::Error => e
    connection&.update!(last_error: e.message)
  end
end

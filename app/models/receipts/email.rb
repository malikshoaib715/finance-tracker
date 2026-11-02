# The parts of an email the parsers look at. Built from Gmail API messages or
# inbound (forwarded) mail; the body is used for parsing and then discarded.
Receipts::Email = Data.define(:message_id, :from, :subject, :date, :text) do
  def sender = from.to_s[/[\w.+-]+@[\w.-]+/].to_s.downcase
  def evidence = "#{sender} — #{subject}".truncate(200)
end

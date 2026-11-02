# Receipts forwarded to a user's private address. Works for automatic
# forwarding rules (original sender kept) and manual "Forward" (original sender
# and subject read from the forwarded block). Only extracted facts are kept;
# the inbound email itself is incinerated by Action Mailbox after processing.
class ReceiptsMailbox < ApplicationMailbox
  FORWARDED = /^-{5,} Forwarded message -{5,}\s*\nFrom:\s*(?<from>[^\n]+)\n(?:Date:\s*(?<date>[^\n]+)\n)?Subject:\s*(?<subject>[^\n]+)/i

  before_processing :require_user

  def process
    facts = Receipts::Parser.parse(receipt_email)
    Subscriptions::Detector.new(@user).record(facts)
  end

  private

  def require_user
    token = mail.recipients.filter_map { |address| address[/\Areceipts-([a-z0-9]+)@/i, 1] }.first
    @user = User.find_by(receipts_token: token) if token
    bounced! unless @user
  end

  def receipt_email
    text = body_text
    if (forwarded = FORWARDED.match(text))
      Receipts::Email.new(message_id: mail.message_id, from: forwarded[:from], subject: forwarded[:subject].strip,
                          date: (Time.zone.parse(forwarded[:date].to_s) rescue nil) || mail.date || Time.current,
                          text: text)
    else
      Receipts::Email.new(message_id: mail.message_id, from: mail.from&.first.to_s, subject: mail.subject.to_s,
                          date: mail.date || Time.current, text:)
    end
  end

  def body_text
    part = mail.text_part || (mail.multipart? ? nil : mail)
    return part.decoded if part

    ActionController::Base.helpers.strip_tags(mail.html_part&.decoded.to_s).gsub(/\n\s*\n+/, "\n")
  end
end

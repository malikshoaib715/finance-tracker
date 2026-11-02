# Stripe-hosted receipts and failed-payment emails (Anthropic, Cursor, Tripo…).
# The merchant is in the subject: "Your receipt from Anthropic, PBC #2820-2973".
class Receipts::StripeParser
  def self.handles?(email)
    email.sender.end_with?("@stripe.com") || email.subject.match?(/\AYour receipt from /i)
  end

  def self.parse(email)
    merchant = email.subject[/receipt from (.+?)(?:,? (?:PBC|Inc\.?|LLC|Ltd\.?))?\s*#/i, 1] or return []
    cents, currency = Receipts::MoneyText.first(email.text[/Amount paid[^\n]*\n?[^\n]*/i] || email.text)
    [
      Receipts::Fact.new(
        service: merchant.strip, kind: "charged", occurred_on: email.date.to_date, amount_cents: cents,
        currency:, plan: email.text[/^(.+?)\s+Qty\b/i, 1]&.strip, card_last4: Receipts::MoneyText.card_last4(email.text),
        source_ref: email.message_id, evidence: email.evidence
      )
    ]
  end
end

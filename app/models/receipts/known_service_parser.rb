# Services that bill directly and email in a predictable way. Each rule maps a
# sender domain to a service name, and subject patterns to what happened.
# Adding a service is one entry here plus a test.
class Receipts::KnownServiceParser
  Rule = Data.define(:service, :sender, :billed_via, :subjects)

  RULES = [
    Rule.new("Netflix", /@(?:account\.)?netflix\.com\z/, "direct", {
      /declined|payment (?:failed|issue)|on hold|update your payment/i => "failed",
      /membership (?:has been )?cancel/i => "canceled",
      /welcome back|payment (?:received|confirmation)/i => "charged"
    }),
    Rule.new("Spotify Premium", /@spotify\.com\z/, "direct", {
      /payment (?:issue|failed)|couldn.t process/i => "failed",
      /no longer on spotify premium|premium (?:has )?ended/i => "canceled",
      /order confirmation|receipt/i => "charged"
    }),
    Rule.new("LinkedIn Premium", /@linkedin\.com\z/, "direct", {
      /problem processing your payment|update your payment/i => "failed",
      /have canceled premium|premium .*canceled/i => "canceled",
      /thank you for purchasing premium|your premium (?:receipt|invoice)/i => "charged"
    }),
    Rule.new("YouTube Premium", /@youtube\.com\z/, "direct", {
      /paused|payment (?:failed|declined)|couldn.t process/i => "failed",
      /membership (?:has )?ended|cancel/i => "canceled",
      /you.re now a youtube premium member|good to go|receipt/i => "charged"
    }),
    Rule.new(nil, /\Agoogleplay-noreply@google\.com\z/, "google_play", {
      /order receipt/i => "charged",
      /cancel/i => "canceled",
      /payment (?:declined|failed)/i => "failed"
    })
  ].freeze

  def self.handles?(email) = RULES.any? { |rule| email.sender.match?(rule.sender) }

  def self.parse(email)
    rule = RULES.find { |r| email.sender.match?(r.sender) } or return []
    kind = rule.subjects.find { |pattern, _| email.subject.match?(pattern) }&.last or return []
    service = rule.service || email.text[/^(?:Item|Subscription):\s*(.+)$/i, 1]&.strip or return []
    cents, currency = Receipts::MoneyText.first(email.text) if kind == "charged"

    [
      Receipts::Fact.new(service:, kind:, occurred_on: email.date.to_date, amount_cents: cents, currency:,
                         card_last4: Receipts::MoneyText.card_last4(email.text), billed_via: rule.billed_via,
                         source_ref: email.message_id, evidence: email.evidence)
    ]
  end
end

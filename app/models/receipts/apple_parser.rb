# Apple's receipts, invoices, "Subscription is Confirmed/Expiring" and
# "Billing Problem" emails from no_reply@email.apple.com.
class Receipts::AppleParser
  SENDER = "no_reply@email.apple.com"

  def self.handles?(email) = email.sender == SENDER

  def self.parse(email)
    case email.subject
    when /receipt|invoice/i then charges(email)
    when /subscription is confirmed/i then [ fact(email, "trial_started", service_line(email.text)) ].compact
    when /subscription is expiring/i then [ fact(email, "canceled", service_line(email.text)) ].compact
    when /billing problem/i then [ fact(email, "failed", service_line(email.text) || "Apple subscription") ].compact
    else []
    end
  end

  # A receipt can list several items; each item block is "Service\nPlan (Monthly)\nRenews …\nRs 800.00".
  def self.charges(email)
    card = Receipts::MoneyText.card_last4(email.text)
    email.text.scan(/^(?<service>[^\n]+)\n(?<plan>[^\n]*\((?<interval>Weekly|Monthly|Yearly|Annual|7 days)\)[^\n]*)\n(?:Renews (?<renews>[^\n]+)\n)?(?<amount>[^\n]*\d[^\n]*)$/i).filter_map do |service, plan, interval, renews, amount_line|
      cents, currency = Receipts::MoneyText.first(amount_line)
      next unless cents

      Receipts::Fact.new(
        service: service.strip, kind: "charged", occurred_on: email.date.to_date, amount_cents: cents,
        currency:, interval: normalize_interval(interval), plan: plan.strip, card_last4: card,
        billed_via: "apple", next_renewal_on: (Date.parse(renews) rescue nil),
        source_ref: email.message_id, evidence: email.evidence
      )
    end
  end

  def self.service_line(text) = text.to_s[/^(?:Subscription|App):\s*(.+)$/i, 1]&.strip

  def self.fact(email, kind, service)
    return unless service

    Receipts::Fact.new(service:, kind:, occurred_on: email.date.to_date, billed_via: "apple",
                       source_ref: email.message_id, evidence: email.evidence)
  end

  def self.normalize_interval(word)
    { "weekly" => "weekly", "7 days" => "weekly", "monthly" => "monthly", "yearly" => "yearly", "annual" => "yearly" }
      .fetch(word.downcase, "monthly")
  end
end

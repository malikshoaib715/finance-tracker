# One thing a receipt tells us about a subscription.
Receipts::Fact = Data.define(:service, :kind, :occurred_on, :amount_cents, :currency, :interval,
                             :plan, :card_last4, :billed_via, :next_renewal_on, :source_ref, :evidence) do
  def initialize(service:, kind:, occurred_on:, amount_cents: nil, currency: nil, interval: nil, plan: nil,
                 card_last4: nil, billed_via: "direct", next_renewal_on: nil, source_ref: nil, evidence: nil)
    super
  end
end

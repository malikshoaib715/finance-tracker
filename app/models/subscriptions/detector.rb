# Folds receipt facts into a user's subscriptions. Safe to run repeatedly over
# the same emails: an event is recorded once per (source, source_ref).
class Subscriptions::Detector
  def initialize(user, source: "email")
    @user = user
    @source = source
  end

  # Returns the subscriptions that changed.
  def record(facts)
    facts.sort_by(&:occurred_on).filter_map { |fact| apply(fact) }.uniq
  end

  private

  def apply(fact)
    Subscription.transaction do
      subscription = find_or_build(fact.service)
      return if fact.source_ref && SubscriptionEvent.exists?(source: @source, source_ref: fact.source_ref,
                                                             subscription_id: subscription.id)

      subscription.billed_via = fact.billed_via if subscription.new_record? || fact.billed_via != "direct"
      subscription.save! if subscription.new_record?

      note_price_change(subscription, fact)
      subscription.events.create!(
        kind: fact.kind, occurred_on: fact.occurred_on, amount_cents: fact.amount_cents, currency: fact.currency,
        card_last4: fact.card_last4, source: @source, source_ref: fact.source_ref, evidence: fact.evidence
      )
      refresh(subscription, fact)
      subscription
    end
  end

  def find_or_build(service)
    @user.subscriptions.where("lower(service) = ?", service.downcase).first ||
      @user.subscriptions.build(service:)
  end

  def note_price_change(subscription, fact)
    return unless fact.kind == "charged" && fact.amount_cents && subscription.amount_cents
    return if fact.currency != subscription.currency || fact.amount_cents == subscription.amount_cents
    return if subscription.last_charged_on && fact.occurred_on < subscription.last_charged_on

    subscription.events.create!(kind: "price_changed", occurred_on: fact.occurred_on, amount_cents: fact.amount_cents,
                                currency: fact.currency, source: @source,
                                evidence: "#{subscription.amount_cents} → #{fact.amount_cents} #{fact.currency}")
  end

  # Latest known values win; status follows the most recent event.
  def refresh(subscription, fact)
    if fact.kind == "charged" && (subscription.last_charged_on.nil? || fact.occurred_on >= subscription.last_charged_on)
      subscription.assign_attributes(
        last_charged_on: fact.occurred_on,
        amount_cents: fact.amount_cents || subscription.amount_cents,
        currency: fact.currency || subscription.currency,
        interval: fact.interval || subscription.interval,
        plan: fact.plan || subscription.plan,
        next_renewal_on: fact.next_renewal_on || subscription.next_renewal_on
      )
    end
    subscription.card_last4 = fact.card_last4 if fact.card_last4

    latest = subscription.events.where.not(kind: "price_changed").reorder(:occurred_on, :id).last
    subscription.status = { "charged" => "active", "failed" => "failing", "canceled" => "canceled",
                            "trial_started" => "trial" }.fetch(latest.kind)
    subscription.save!
  end
end

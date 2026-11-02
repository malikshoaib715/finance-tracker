# Things worth telling the user about their subscriptions.
class Subscriptions::Alerts
  Alert = Data.define(:level, :message)

  def initialize(subscriptions, today: Date.current)
    @subscriptions = subscriptions
    @today = today
  end

  def to_a
    @subscriptions.flat_map do |s|
      alerts = []
      failures = s.recent_failures(since: @today - 60)
      if s.failing?
        card = failures.filter_map(&:card_last4).last || s.card_last4
        alerts << Alert.new(:danger, "#{s.service}: payment failing#{" on card ••#{card}" if card} " \
                                     "(#{failures.size} failure#{"s" unless failures.size == 1} in 60 days)")
      end
      if s.weekly? && s.amount_cents
        alerts << Alert.new(:warning, "#{s.service} bills weekly — about #{(s.monthly_cents / 100.0).round} #{s.currency} a month")
      end
      if s.trial?
        alerts << Alert.new(:warning, "#{s.service} is on a trial#{" — renews #{s.next_renewal_on}" if s.next_renewal_on}")
      end
      if (change = s.events.select(&:price_changed?).last) && change.occurred_on >= @today - 90
        alerts << Alert.new(:info, "#{s.service} changed price: #{change.evidence}")
      end
      alerts
    end
  end
end

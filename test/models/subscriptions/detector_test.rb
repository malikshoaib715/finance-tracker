require "test_helper"

class Subscriptions::DetectorTest < ActiveSupport::TestCase
  def fact(service, kind, on, **attrs)
    Receipts::Fact.new(service:, kind:, occurred_on: Date.parse(on), source_ref: "#{service}-#{kind}-#{on}", **attrs)
  end

  setup { @user = users(:bilal) }

  test "builds a subscription and its history from facts" do
    Subscriptions::Detector.new(@user).record([
      fact("Netflix", "charged", "2026-02-24", amount_cents: 110_000, currency: "PKR", card_last4: "4792"),
      fact("Netflix", "failed", "2026-10-21", card_last4: "9729")
    ])

    netflix = @user.subscriptions.find_by!(service: "Netflix")
    assert_equal [ "failing", 110_000, "9729", Date.new(2026, 2, 24) ],
                 [ netflix.status, netflix.amount_cents, netflix.card_last4, netflix.last_charged_on ]
    assert_equal %w[charged failed], netflix.events.map(&:kind)
  end

  test "is idempotent over the same emails" do
    facts = [ fact("iCloud+", "charged", "2026-10-21", amount_cents: 80_000, currency: "PKR") ]
    detector = Subscriptions::Detector.new(@user)

    assert_difference "SubscriptionEvent.count", 1 do
      2.times { detector.record(facts) }
    end
  end

  test "matches services case-insensitively and follows the latest event" do
    Subscriptions::Detector.new(@user).record([
      fact("Spotify Premium", "canceled", "2026-07-10"),
      fact("spotify premium", "charged", "2026-08-14", amount_cents: 37_900, currency: "PKR")
    ])
    assert_equal "active", @user.subscriptions.sole.status
  end

  test "records price changes" do
    Subscriptions::Detector.new(@user).record([
      fact("Spotify Premium", "charged", "2026-05-28", amount_cents: 34_900, currency: "PKR"),
      fact("Spotify Premium", "charged", "2026-06-28", amount_cents: 37_900, currency: "PKR")
    ])
    sub = @user.subscriptions.sole
    assert_equal 37_900, sub.amount_cents
    assert_equal [ "price_changed" ], sub.events.price_changed.map(&:kind)
  end

  test "facts arriving out of order don't roll back the latest charge" do
    Subscriptions::Detector.new(@user).record([ fact("iCloud+", "charged", "2026-10-21", amount_cents: 80_000, currency: "PKR") ])
    Subscriptions::Detector.new(@user).record([ fact("iCloud+", "charged", "2026-01-13", amount_cents: 75_000, currency: "PKR") ])

    sub = @user.subscriptions.sole
    assert_equal [ Date.new(2026, 10, 21), 80_000 ], [ sub.last_charged_on, sub.amount_cents ]
    assert_empty sub.events.price_changed
  end
end

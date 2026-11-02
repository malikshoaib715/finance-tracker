require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  test "works out a monthly cost from weekly and yearly prices" do
    assert_equal 80_000, subscriptions(:ayesha_icloud).monthly_cents
    assert_equal 476_667, subscriptions(:ayesha_drama).monthly_cents # Rs 1,100 × 52 / 12
    assert_nil users(:ayesha).subscriptions.build(service: "X").monthly_cents
  end

  test "one record per service per user, ignoring case" do
    assert_not users(:ayesha).subscriptions.build(service: "icloud+").valid?
    assert users(:bilal).subscriptions.build(service: "iCloud+").valid?
  end

  test "card must be the last four digits only" do
    sub = subscriptions(:ayesha_icloud)
    sub.card_last4 = "4111111111111111"
    assert_not sub.valid?
  end

  test "recent failures" do
    sub = subscriptions(:ayesha_icloud)
    sub.events.create!(kind: "failed", occurred_on: Date.current, source: "email")
    assert_equal 1, sub.reload.recent_failures.size
  end
end

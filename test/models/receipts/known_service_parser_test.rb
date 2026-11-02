require "test_helper"

class Receipts::KnownServiceParserTest < ActiveSupport::TestCase
  def parse(from, subject, text = "")
    Receipts::Parser.parse(Receipts::Email.new(message_id: "m1", from:, subject:, date: Time.zone.parse("2026-10-21"), text:))
  end

  test "Netflix declines and comebacks" do
    assert_equal %w[Netflix failed], parse("info@account.netflix.com", "Your payment was declined", "Card ending in 9729")
      .sole.to_h.values_at(:service, :kind)
    assert_equal "9729", parse("info@account.netflix.com", "Your payment was declined", "Card ending in 9729").sole.card_last4
    assert_equal "charged", parse("info@account.netflix.com", "Welcome back to Netflix!").sole.kind
  end

  test "Spotify orders and lapses" do
    order = parse("no-reply@spotify.com", "Your order confirmation for Premium Individual", "Total PKR 379").sole
    assert_equal [ "Spotify Premium", "charged", 37_900, "PKR" ], order.to_h.values_at(:service, :kind, :amount_cents, :currency)
    assert_equal "canceled", parse("no-reply@spotify.com", "You're no longer on Spotify Premium").sole.kind
  end

  test "LinkedIn purchases, failures and cancellations" do
    assert_equal "charged", parse("billing-noreply@linkedin.com", "Thank you for purchasing Premium Career").sole.kind
    assert_equal "failed", parse("billing-noreply@linkedin.com", "Action Needed: There was a problem processing your payment method").sole.kind
    assert_equal "canceled", parse("billing-noreply@linkedin.com", "You have canceled Premium Career").sole.kind
  end

  test "YouTube pauses" do
    assert_equal %w[YouTube\ Premium failed], parse("no-reply@youtube.com", "Your membership is paused").sole.to_h.values_at(:service, :kind)
  end

  test "Google Play receipts name the item in the body" do
    fact = parse("googleplay-noreply@google.com", "Your Google Play Order Receipt from Oct 1, 2026",
                 "Item: Duolingo Super (Monthly)\nTotal: Rs 999.00").sole
    assert_equal [ "Duolingo Super (Monthly)", 99_900, "google_play" ], fact.to_h.values_at(:service, :amount_cents, :billed_via)
  end

  test "marketing from the same senders is ignored" do
    assert_empty parse("info@account.netflix.com", "New on Netflix this week")
  end
end

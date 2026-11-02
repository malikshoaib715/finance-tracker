require "test_helper"

class Receipts::ParserTest < ActiveSupport::TestCase
  def email(from:, subject:, text: "", date: Time.zone.parse("2026-10-21 10:00"))
    Receipts::Email.new(message_id: "m-#{subject.hash}", from:, subject:, date:, text:)
  end

  test "reads every item on an Apple receipt" do
    facts = Receipts::Parser.parse(email(
      from: "Apple <no_reply@email.apple.com>", subject: "Your receipt from Apple.",
      text: file_fixture("receipts/apple_receipt.txt").read
    ))

    assert_equal [ "iCloud+", "YouTube" ], facts.map(&:service)
    icloud = facts.first
    assert_equal [ 80_000, "PKR", "monthly", "9729", "apple" ], icloud.to_h.values_at(:amount_cents, :currency, :interval, :card_last4, :billed_via)
    assert_equal Date.new(2026, 11, 18), icloud.next_renewal_on
    assert_equal "no_reply@email.apple.com — Your receipt from Apple.", icloud.evidence
  end

  test "Apple billing problems and expiry notices become failed and canceled facts" do
    failed = Receipts::Parser.parse(email(from: "no_reply@email.apple.com", subject: "Billing Problem",
                                          text: "Subscription: iCloud+\nWe couldn't charge your card."))
    expiring = Receipts::Parser.parse(email(from: "no_reply@email.apple.com", subject: "Your Subscription is Expiring",
                                            text: "Subscription: YouTube Premium\nExpires 13 August 2026"))

    assert_equal [ "iCloud+", "failed" ], failed.sole.to_h.values_at(:service, :kind)
    assert_equal [ "YouTube Premium", "canceled" ], expiring.sole.to_h.values_at(:service, :kind)
  end

  test "reads a Stripe receipt" do
    fact = Receipts::Parser.parse(email(
      from: "invoice+statements@stripe.com", subject: "Your receipt from Anthropic, PBC #2820-2973-2015",
      text: file_fixture("receipts/stripe_receipt.txt").read
    )).sole

    assert_equal [ "Anthropic", 2_000, "USD", "1922", "Claude Pro" ],
                 fact.to_h.values_at(:service, :amount_cents, :currency, :card_last4, :plan)
  end

  test "ignores senders it doesn't know" do
    assert_empty Receipts::Parser.parse(email(from: "news@example.com", subject: "Big sale!"))
  end

  test "money text understands local formats" do
    assert_equal [ 110_000, "PKR" ], Receipts::MoneyText.first("Total Rs 1,100.00")
    assert_equal [ 89_900, "PKR" ], Receipts::MoneyText.first("PKR 899 per month")
    assert_equal [ 9_368, "USD" ], Receipts::MoneyText.first("Amount paid $93.68")
    assert_equal "8685", Receipts::MoneyText.card_last4("Visa •••• 8685")
    assert_equal "4792", Receipts::MoneyText.card_last4("card ending in 4792")
    assert_equal "1922", Receipts::MoneyText.card_last4("Payment method\nMastercard - 1922")
  end
end

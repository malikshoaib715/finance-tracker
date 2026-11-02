require "test_helper"

class ReceiptsMailboxTest < ActionMailbox::TestCase
  setup do
    @user = users(:bilal)
    @user.regenerate_receipts_token
  end

  test "an auto-forwarded receipt keeps its sender and creates a subscription" do
    receive_inbound_email_from_mail(
      to: @user.receipts_address, from: "Apple <no_reply@email.apple.com>",
      subject: "Your receipt from Apple.", body: file_fixture("receipts/apple_receipt.txt").read
    )

    assert_equal [ "YouTube", "iCloud+" ].sort, @user.subscriptions.pluck(:service).sort
    assert_equal "9729", @user.subscriptions.find_by!(service: "iCloud+").card_last4
  end

  test "a manually forwarded receipt is read from the forwarded block" do
    receive_inbound_email_from_mail(
      to: @user.receipts_address, from: @user.email, subject: "Fwd: Your payment was declined",
      body: <<~MAIL
        ---------- Forwarded message ---------
        From: Netflix <info@account.netflix.com>
        Date: Tue, 21 Oct 2026 10:00:00 +0500
        Subject: Your payment was declined

        We couldn't process your payment. Card ending in 9729.
      MAIL
    )

    netflix = @user.subscriptions.find_by!(service: "Netflix")
    assert_equal [ "failing", "9729" ], [ netflix.status, netflix.card_last4 ]
  end

  test "an unknown address bounces" do
    inbound = receive_inbound_email_from_mail(to: "receipts-nobody@inbound.financetracker.app",
                                              from: "x@example.com", subject: "hi", body: "hello")
    assert inbound.bounced?
  end
end

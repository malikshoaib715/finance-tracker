# One dated fact about a subscription: a charge, a failed payment, a cancellation…
# Stores only extracted fields plus a short evidence line (sender + subject),
# never the email itself.
class SubscriptionEvent < ApplicationRecord
  belongs_to :subscription, touch: true

  enum :kind, {
    charged: "charged", failed: "failed", canceled: "canceled",
    trial_started: "trial_started", price_changed: "price_changed"
  }, validate: true

  validates :occurred_on, :source, presence: true
  validates :evidence, length: { maximum: 200 }
end

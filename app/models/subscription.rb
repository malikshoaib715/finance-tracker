# A recurring charge we've detected for a user (Netflix, iCloud+, Claude…),
# built up from SubscriptionEvents found in receipts or bank transactions.
class Subscription < ApplicationRecord
  INTERVAL_MONTHS = { "weekly" => 12.0 / 52, "monthly" => 1.0, "quarterly" => 3.0, "yearly" => 12.0 }.freeze

  belongs_to :user
  has_many :events, -> { order(:occurred_on, :id) }, class_name: "SubscriptionEvent", dependent: :delete_all

  enum :interval, INTERVAL_MONTHS.keys.index_with(&:itself), default: :monthly, validate: true
  enum :status, { active: "active", failing: "failing", trial: "trial", canceled: "canceled" }, default: :active, validate: true
  enum :billed_via, { apple: "apple", google_play: "google_play", direct: "direct" }, default: :direct, validate: true, prefix: :billed_via

  normalizes :service, with: ->(service) { service.squish }

  validates :service, presence: true, length: { maximum: 80 }, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :currency, length: { is: 3 }, allow_nil: true
  validates :card_last4, format: { with: /\A\d{4}\z/ }, allow_nil: true

  scope :current, -> { where(status: %w[active failing trial]) }
  scope :by_service, -> { order(Arel.sql("lower(service)")) }

  # What this costs per month, for totals. Nil when the price isn't known.
  def monthly_cents
    (amount_cents / INTERVAL_MONTHS.fetch(interval)).round if amount_cents
  end

  def recent_failures(since: 60.days.ago.to_date)
    events.select { |e| e.failed? && e.occurred_on >= since }
  end
end

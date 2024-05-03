# A template for a transaction that repeats: salary, rent, subscriptions.
class RecurringTransaction < ApplicationRecord
  FREQUENCIES = { "weekly" => 1.week, "monthly" => 1.month, "quarterly" => 3.months, "yearly" => 1.year }.freeze

  belongs_to :user
  belongs_to :account
  belongs_to :category, optional: true

  enum :kind, { expense: "expense", income: "income" }, default: :expense, validate: true
  enum :frequency, FREQUENCIES.keys.index_with(&:itself), default: :monthly, validate: true

  normalizes :description, with: ->(description) { description.squish }

  validates :description, presence: true, length: { maximum: 120 }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :next_on, presence: true
  validate :ends_after_next, if: :active?
  validate :belongs_to_same_user

  scope :active, -> { where(active: true) }
  scope :due, ->(on = Date.current) { active.where(next_on: ..on) }
  scope :upcoming, ->(within = 14.days) { active.where(next_on: Date.current..(Date.current + within)).order(:next_on) }

  def amount
    amount_cents.to_i / 100.0 if amount_cents
  end

  def amount=(value)
    self.amount_cents = (BigDecimal(value.to_s.delete(",")) * 100).round.abs
  rescue ArgumentError, TypeError
    self.amount_cents = nil
  end

  def signed_amount_cents
    income? ? amount_cents : -amount_cents
  end

  # The date after +date+. Monthly items anchored on the 31st land on the last
  # day of shorter months (Rails' month arithmetic clamps), then stay there.
  def following(date)
    date + FREQUENCIES.fetch(frequency)
  end

  def finished?
    ends_on.present? && next_on > ends_on
  end

  private

  def ends_after_next
    errors.add(:ends_on, "must be on or after the next date") if ends_on && next_on && ends_on < next_on
  end

  def belongs_to_same_user
    errors.add(:account, "is not one of yours") if account && account.user_id != user_id
    errors.add(:category, "is not one of yours") if category && category.user_id != user_id
  end
end

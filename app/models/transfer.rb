class Transfer < ApplicationRecord
  belongs_to :user
  belongs_to :from_account, class_name: "Account"
  belongs_to :to_account, class_name: "Account"

  normalizes :description, with: ->(description) { description.squish.presence }

  validates :occurred_on, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validate :accounts_belong_to_user
  validate :accounts_differ
  validate :same_currency

  scope :recent_first, -> { order(occurred_on: :desc, id: :desc) }

  def amount
    amount_cents.to_i / 100.0 if amount_cents
  end

  def amount=(value)
    self.amount_cents = (BigDecimal(value.to_s.delete(",")) * 100).round.abs
  rescue ArgumentError, TypeError
    self.amount_cents = nil
  end

  def title
    description || "Transfer to #{to_account.name}"
  end

  private

  def accounts_belong_to_user
    errors.add(:from_account, "is not one of yours") if from_account && from_account.user_id != user_id
    errors.add(:to_account, "is not one of yours") if to_account && to_account.user_id != user_id
  end

  def accounts_differ
    errors.add(:to_account, "must be different from the account you're moving money from") if from_account_id.present? && from_account_id == to_account_id
  end

  # Cross-currency transfers need an exchange rate; keep them out until that exists.
  def same_currency
    return unless from_account && to_account && from_account.currency != to_account.currency

    errors.add(:to_account, "must use the same currency (#{from_account.currency})")
  end
end

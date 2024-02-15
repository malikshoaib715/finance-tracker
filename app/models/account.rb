class Account < ApplicationRecord
  belongs_to :user

  enum :kind, {
    cash: "cash", bank: "bank", credit_card: "credit_card", wallet: "wallet", savings: "savings"
  }, default: :bank, validate: true

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :currency, inclusion: { in: User::CURRENCIES }

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :alphabetical, -> { order(:name) }

  def archived?
    archived_at.present?
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def unarchive!
    update!(archived_at: nil)
  end

  def balance_cents
    opening_balance_cents
  end

  # Forms work in major units ("1500.50"); storage is in minor units.
  def opening_balance
    opening_balance_cents.to_i / 100.0
  end

  def opening_balance=(value)
    self.opening_balance_cents = (BigDecimal(value.to_s.delete(",").presence || "0") * 100).round
  rescue ArgumentError
    errors.add(:opening_balance, "is not a number")
  end
end

class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_error
  has_many :outgoing_transfers, class_name: "Transfer", foreign_key: :from_account_id, dependent: :restrict_with_error
  has_many :incoming_transfers, class_name: "Transfer", foreign_key: :to_account_id, dependent: :restrict_with_error

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
    opening_balance_cents +
      transactions.income.sum(:amount_cents) - transactions.expense.sum(:amount_cents) +
      incoming_transfers.sum(:amount_cents) - outgoing_transfers.sum(:amount_cents)
  end

  Entry = Data.define(:record, :occurred_on, :title, :amount_cents, :balance_cents)

  # Every movement on the account, oldest first, with the balance after each one.
  def ledger
    movements = transactions.includes(:category).map { |t| [ t, t.occurred_on, t.created_at, t.description, t.signed_amount_cents ] } +
      incoming_transfers.includes(:from_account).map { |t| [ t, t.occurred_on, t.created_at, "From #{t.from_account.name}", t.amount_cents ] } +
      outgoing_transfers.includes(:to_account).map { |t| [ t, t.occurred_on, t.created_at, "To #{t.to_account.name}", -t.amount_cents ] }

    balance = opening_balance_cents
    movements.sort_by { |m| m[1..2] }.map do |record, occurred_on, _created_at, title, amount|
      balance += amount
      Entry.new(record:, occurred_on:, title:, amount_cents: amount, balance_cents: balance)
    end
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

class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_error
  has_many :imports, dependent: :delete_all
  has_many :recurring_transactions, dependent: :delete_all
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
  scope :ordered, -> { order(:position, :name) }

  before_create { self.position = (user.accounts.maximum(:position) || 0) + 1 }

  # Swap places with the neighbour above (-1) or below (+1).
  def move(direction)
    siblings = user.accounts.active.ordered.to_a
    index = siblings.index(self)
    neighbour = siblings[index + direction] if index && (index + direction).between?(0, siblings.size - 1)
    return unless neighbour

    transaction do
      mine, theirs = position, neighbour.position
      mine, theirs = index + 1, index + 1 + direction if mine == theirs
      update!(position: theirs)
      neighbour.update!(position: mine)
    end
  end

  # Loads each account's balance in the same query (one correlated subquery per
  # movement type) so lists don't run four SUMs per account.
  scope :with_balances, -> {
    select(<<~SQL.squish)
      accounts.*,
      accounts.opening_balance_cents
        + COALESCE((SELECT SUM(CASE WHEN t.kind = 'income' THEN t.amount_cents ELSE -t.amount_cents END)
                    FROM transactions t WHERE t.account_id = accounts.id), 0)
        + COALESCE((SELECT SUM(tr.amount_cents) FROM transfers tr WHERE tr.to_account_id = accounts.id), 0)
        - COALESCE((SELECT SUM(tr.amount_cents) FROM transfers tr WHERE tr.from_account_id = accounts.id), 0)
        AS computed_balance_cents
    SQL
  }

  def deletable?
    !transactions.exists? && !incoming_transfers.exists? && !outgoing_transfers.exists?
  end

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
    return self[:computed_balance_cents].to_i if has_attribute?(:computed_balance_cents)

    opening_balance_cents +
      transactions.income.sum(:amount_cents) - transactions.expense.sum(:amount_cents) +
      incoming_transfers.sum(:amount_cents) - outgoing_transfers.sum(:amount_cents)
  end

  Entry = Data.define(:record, :occurred_on, :title, :amount_cents, :balance_cents)

  # Every movement on the account, oldest first, with the balance after each one.
  def ledger
    movements = transactions.map { |t| [ t, t.occurred_on, t.created_at, t.description, t.signed_amount_cents ] } +
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

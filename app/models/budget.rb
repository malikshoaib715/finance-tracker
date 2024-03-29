class Budget < ApplicationRecord
  WARNING_RATIO = 0.8

  belongs_to :user
  belongs_to :category

  normalizes :month, with: ->(month) { month.to_date.beginning_of_month }

  validates :month, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :category_id, uniqueness: { scope: [ :user_id, :month ], message: "already has a budget this month" }
  validate :category_is_an_expense_of_the_user

  scope :for_month, ->(month) { where(month: month.to_date.beginning_of_month) }

  # Adds each budget's spending as a column so lists don't run a SUM per budget.
  scope :with_spending, -> {
    select(<<~SQL.squish)
      budgets.*,
      COALESCE((
        SELECT SUM(t.amount_cents) FROM transactions t
        WHERE t.user_id = budgets.user_id AND t.category_id = budgets.category_id AND t.kind = 'expense'
          AND t.occurred_on >= budgets.month AND t.occurred_on < budgets.month + INTERVAL '1 month'
      ), 0) AS computed_spent_cents
    SQL
  }

  # Copies the previous month's limits into +month+, skipping categories that
  # already have a budget there. Returns the budgets created.
  def self.copy_previous_month(user, month)
    month = month.to_date.beginning_of_month
    existing = user.budgets.for_month(month).pluck(:category_id)

    user.budgets.for_month(month.prev_month).where.not(category_id: existing).map do |previous|
      user.budgets.create!(category_id: previous.category_id, month: month, amount_cents: previous.amount_cents)
    end
  end

  def amount
    amount_cents.to_i / 100.0 if amount_cents
  end

  def amount=(value)
    self.amount_cents = (BigDecimal(value.to_s.delete(",")) * 100).round
  rescue ArgumentError, TypeError
    self.amount_cents = nil
  end

  def spent_cents
    return self[:computed_spent_cents] if has_attribute?(:computed_spent_cents)

    @spent_cents ||= user.transactions.expense.where(category: category, occurred_on: month.all_month).sum(:amount_cents)
  end

  def remaining_cents
    amount_cents - spent_cents
  end

  def ratio
    spent_cents.fdiv(amount_cents)
  end

  def status
    if ratio > 1 then :over
    elsif ratio >= WARNING_RATIO then :warning
    else :ok
    end
  end

  private

  def category_is_an_expense_of_the_user
    return if category.nil?

    errors.add(:category, "is not one of yours") if category.user_id != user_id
    errors.add(:category, "must be an expense category") unless category.expense?
  end
end

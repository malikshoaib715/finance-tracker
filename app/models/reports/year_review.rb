# One calendar year at a glance.
class Reports::YearReview
  attr_reader :year

  def initialize(user, year: Date.current.year)
    @user = user
    @year = year
  end

  def income_cents = totals.fetch("income", 0)
  def expense_cents = totals.fetch("expense", 0)
  def saved_cents = income_cents - expense_cents

  # Share of income kept, e.g. 0.18 for 18%. Nil when there was no income.
  def savings_rate
    saved_cents.fdiv(income_cents) if income_cents.positive?
  end

  def top_categories(limit = 5)
    transactions.expense.left_joins(:category)
      .group(Arel.sql("COALESCE(categories.name, 'Uncategorised')"))
      .order(Arel.sql("SUM(transactions.amount_cents) DESC")).limit(limit)
      .sum(:amount_cents)
  end

  # [month, cents] of the month with the most spending.
  def biggest_month
    monthly_expenses.max_by(&:last)
  end

  def monthly_expenses
    @monthly_expenses ||= transactions.expense
      .group_by_month(:occurred_on, range: range, format: "%B").sum(:amount_cents)
  end

  private

  def range = Date.new(year).all_year

  def transactions = @user.transactions.where(occurred_on: range)

  def totals
    @totals ||= transactions.group(:kind).sum(:amount_cents)
  end
end

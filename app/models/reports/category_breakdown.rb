# Spending per expense category for a month, with its share of the total and
# the change against the previous month.
class Reports::CategoryBreakdown
  Row = Data.define(:category_id, :name, :color, :amount_cents, :previous_cents, :share) do
    def change_cents = amount_cents - previous_cents
  end

  attr_reader :month

  def initialize(user, month: Date.current)
    @user = user
    @month = month.to_date.beginning_of_month
  end

  def rows
    @rows ||= begin
      current = totals(@month)
      previous = totals(@month.prev_month)
      total = current.values.sum

      (current.keys | previous.keys).map do |key|
        category_id, name, color = key
        amount = current.fetch(key, 0)
        Row.new(category_id:, name:, color:, amount_cents: amount, previous_cents: previous.fetch(key, 0),
                share: total.zero? ? 0 : amount.fdiv(total))
      end.sort_by { |row| -row.amount_cents }
    end
  end

  def total_cents
    rows.sum(&:amount_cents)
  end

  private

  def totals(month)
    @user.transactions.expense.where(occurred_on: month.all_month).left_joins(:category)
      .group("categories.id", Arel.sql("COALESCE(categories.name, 'Uncategorised')"), Arel.sql("COALESCE(categories.color, 'slate')"))
      .sum(:amount_cents)
  end
end

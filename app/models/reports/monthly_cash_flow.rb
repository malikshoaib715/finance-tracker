# Income and expenses per month for the last +months+ months, ending with the
# current one. Months with no activity are included as zero.
class Reports::MonthlyCashFlow
  def initialize(user, months: 12, today: Date.current)
    @user = user
    @range = (today.beginning_of_month << (months - 1))..today.end_of_month
  end

  def income
    series(:income)
  end

  def expense
    series(:expense)
  end

  def net
    income.merge(expense) { |_month, inc, exp| (inc - exp).round(2) }
  end

  def chart_data
    [ { name: "Income", data: income }, { name: "Expenses", data: expense } ]
  end

  private

  def series(kind)
    @user.transactions.public_send(kind)
      .group_by_month(:occurred_on, range: @range, format: "%b %Y")
      .sum(:amount_cents)
      .transform_values { |cents| cents / 100.0 }
  end
end

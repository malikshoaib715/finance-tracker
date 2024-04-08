# Total balance across the user's accounts (in their default currency) at the
# end of each of the last +months+ months. Transfers move money between
# accounts, so they don't change the total and can be ignored here.
class Reports::NetWorth
  def initialize(user, months: 12, today: Date.current)
    @user = user
    @months = months
    @today = today
  end

  # Three queries regardless of the number of months: opening balances, the
  # movements before the window, and one grouped SUM per month accumulated in Ruby.
  def series
    accounts = @user.accounts.where(currency: @user.currency)
    signed = Arel.sql("CASE WHEN transactions.kind = 'income' THEN amount_cents ELSE -amount_cents END")
    movements = @user.transactions.where(account: accounts)
    first_month = month_ends.first.beginning_of_month

    running = accounts.sum(:opening_balance_cents) + movements.where(occurred_on: ...first_month).sum(signed)
    per_month = movements.where(occurred_on: first_month..month_ends.last)
      .group(Arel.sql("date_trunc('month', occurred_on)::date")).sum(signed)

    month_ends.to_h do |month_end|
      running += per_month.fetch(month_end.beginning_of_month, 0)
      [ month_end.strftime("%b %Y"), running / 100.0 ]
    end
  end

  def other_currencies?
    @user.accounts.where.not(currency: @user.currency).exists?
  end

  private

  def month_ends
    (0...@months).map { |i| (@today << i).end_of_month }.reverse.map { |date| [ date, @today ].min }
  end
end

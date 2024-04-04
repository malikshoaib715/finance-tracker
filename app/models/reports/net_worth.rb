# Total balance across the user's accounts (in their default currency) at the
# end of each of the last +months+ months. Transfers move money between
# accounts, so they don't change the total and can be ignored here.
class Reports::NetWorth
  def initialize(user, months: 12, today: Date.current)
    @user = user
    @months = months
    @today = today
  end

  def series
    accounts = @user.accounts.where(currency: @user.currency)
    opening = accounts.sum(:opening_balance_cents)
    signed = Arel.sql("CASE WHEN transactions.kind = 'income' THEN amount_cents ELSE -amount_cents END")
    movements = @user.transactions.where(account: accounts)

    month_ends.index_with do |month_end|
      (opening + movements.where(occurred_on: ..month_end).sum(signed)) / 100.0
    end.transform_keys { |date| date.strftime("%b %Y") }
  end

  def other_currencies?
    @user.accounts.where.not(currency: @user.currency).exists?
  end

  private

  def month_ends
    (0...@months).map { |i| (@today << i).end_of_month }.reverse.map { |date| [ date, @today ].min }
  end
end

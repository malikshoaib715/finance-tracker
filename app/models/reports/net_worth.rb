# Total balance across the user's accounts at the end of each of the last
# +months+ months, in their default currency. Accounts in other currencies are
# converted with the user's exchange rates (today's rate for every month, a
# deliberate simplification); currencies without a rate are left out.
# Transfers only happen within one currency, so they cancel out per currency.
class Reports::NetWorth
  def initialize(user, months: 12, today: Date.current)
    @user = user
    @months = months
    @today = today
  end

  def series
    totals = Hash.new(0)
    included_currencies.each do |currency|
      series_cents(currency).each do |month_end, cents|
        totals[month_end] += ExchangeRate.convert(@user, cents, currency)
      end
    end
    month_ends.to_h { |month_end| [ month_end.strftime("%b %Y"), totals[month_end] / 100.0 ] }
  end

  def other_currencies?
    excluded_currencies.any?
  end

  def excluded_currencies
    currencies - included_currencies
  end

  private

  def currencies
    @currencies ||= @user.accounts.distinct.pluck(:currency)
  end

  def included_currencies
    @included ||= currencies.select { |currency| ExchangeRate.convert(@user, 1, currency) }
  end

  # Three queries per currency regardless of the number of months: opening
  # balances, the movements before the window, and one grouped SUM per month.
  def series_cents(currency)
    accounts = @user.accounts.where(currency: currency)
    signed = Arel.sql("CASE WHEN transactions.kind = 'income' THEN amount_cents ELSE -amount_cents END")
    movements = @user.transactions.where(account: accounts)
    first_month = month_ends.first.beginning_of_month

    running = accounts.sum(:opening_balance_cents) + movements.where(occurred_on: ...first_month).sum(signed)
    per_month = movements.where(occurred_on: first_month..month_ends.last)
      .group(Arel.sql("date_trunc('month', occurred_on)::date")).sum(signed)

    month_ends.to_h do |month_end|
      running += per_month.fetch(month_end.beginning_of_month, 0)
      [ month_end, running ]
    end
  end

  def month_ends
    @month_ends ||= (0...@months).map { |i| (@today << i).end_of_month }.reverse.map { |date| [ date, @today ].min }
  end
end

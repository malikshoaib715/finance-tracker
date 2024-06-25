class DashboardController < ApplicationController
  def show
    @onboarding = User::Onboarding.new(current_user)
    @month = Date.current.all_month
    month_transactions = current_user.transactions.where(occurred_on: @month)

    @income_cents = month_transactions.income.sum(:amount_cents)
    @expense_cents = month_transactions.expense.sum(:amount_cents)
    @spending_by_category = month_transactions.expense
      .left_joins(:category).group(Arel.sql("COALESCE(categories.name, 'Uncategorised')"))
      .order(Arel.sql("SUM(transactions.amount_cents) DESC"))
      .sum(:amount_cents).transform_values { |cents| cents / 100.0 }
    @accounts = current_user.accounts.active.ordered.with_balances
    @net_worth_cents = @accounts.sum { |account| ExchangeRate.convert(current_user, account.balance_cents, account.currency) || 0 }
    @budgets = current_user.budgets.for_month(@month.first).with_spending.includes(:category)
      .sort_by { |budget| -budget.ratio }.first(4)
    @upcoming = current_user.recurring_transactions.upcoming.includes(:account).limit(5)
    @recent_transactions = current_user.transactions.includes(:account, :category, :tags, :receipts_attachments).recent_first.limit(5)
  end
end

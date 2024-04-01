class DashboardController < ApplicationController
  def show
    @month = Date.current.all_month
    month_transactions = current_user.transactions.where(occurred_on: @month)

    @income_cents = month_transactions.income.sum(:amount_cents)
    @expense_cents = month_transactions.expense.sum(:amount_cents)
    @spending_by_category = month_transactions.expense
      .left_joins(:category).group(Arel.sql("COALESCE(categories.name, 'Uncategorised')"))
      .order(Arel.sql("SUM(transactions.amount_cents) DESC"))
      .sum(:amount_cents).transform_values { |cents| cents / 100.0 }
    @accounts = current_user.accounts.active.alphabetical.with_balances
    @budgets = current_user.budgets.for_month(@month.first).with_spending.includes(:category)
      .sort_by { |budget| -budget.ratio }.first(4)
    @recent_transactions = current_user.transactions.includes(:account, :category, :tags).recent_first.limit(5)
  end
end

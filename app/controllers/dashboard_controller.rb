class DashboardController < ApplicationController
  def show
    @month = Date.current.all_month
    month_transactions = current_user.transactions.where(occurred_on: @month)

    @income_cents = month_transactions.income.sum(:amount_cents)
    @expense_cents = month_transactions.expense.sum(:amount_cents)
    @accounts = current_user.accounts.active.alphabetical
    @recent_transactions = current_user.transactions.includes(:account, :category).recent_first.limit(5)
  end
end

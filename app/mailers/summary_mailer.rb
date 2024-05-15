class SummaryMailer < ApplicationMailer
  helper MoneyHelper

  # Last month's numbers for one user.
  def monthly(user, month: Date.current.prev_month)
    @user = user
    @month = month.beginning_of_month
    transactions = user.transactions.where(occurred_on: @month.all_month)

    @income_cents = transactions.income.sum(:amount_cents)
    @expense_cents = transactions.expense.sum(:amount_cents)
    @top_categories = Reports::CategoryBreakdown.new(user, month: @month).rows.first(5)
    @budgets = user.budgets.for_month(@month).with_spending.includes(:category).sort_by { |b| -b.ratio }

    mail to: user.email, subject: "Your #{l(@month, format: '%B %Y')} in numbers"
  end
end

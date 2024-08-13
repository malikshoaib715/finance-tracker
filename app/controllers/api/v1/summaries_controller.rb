# Everything the mobile home screen needs in one request.
class Api::V1::SummariesController < Api::V1::BaseController
  def show
    month = Date.current.all_month
    in_month = current_user.transactions.where(occurred_on: month)
    accounts = current_user.accounts.active.ordered.with_balances
    budgets = current_user.budgets.for_month(month.first).with_spending.includes(:category)

    render json: {
      month: month.first.strftime("%Y-%m"),
      currency: current_user.currency,
      income_cents: in_month.income.sum(:amount_cents),
      expense_cents: in_month.expense.sum(:amount_cents),
      net_worth_cents: accounts.sum { |a| ExchangeRate.convert(current_user, a.balance_cents, a.currency) || 0 },
      budgets: budgets.map do |b|
        { id: b.id, category: b.category.name, color: b.category.color, amount_cents: b.amount_cents,
          spent_cents: b.spent_cents, status: b.status }
      end
    }
  end
end

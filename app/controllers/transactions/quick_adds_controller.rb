# One-line expense entry from the dashboard. Rules fill in the category.
class Transactions::QuickAddsController < ApplicationController
  def create
    account = current_user.accounts.find(params.dig(:quick_add, :account_id))
    transaction = current_user.transactions.build(quick_add_params.merge(account:, kind: "expense", occurred_on: Date.current))

    if transaction.save
      redirect_to dashboard_path, notice: "Added #{transaction.description} " \
        "(#{transaction.category&.name || "uncategorised"})."
    else
      redirect_to dashboard_path, alert: transaction.errors.full_messages.to_sentence
    end
  end

  private

  def quick_add_params
    params.require(:quick_add).permit(:amount, :description)
  end
end

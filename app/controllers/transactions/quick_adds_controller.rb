# One-line expense entry from the dashboard. Rules fill in the category.
class Transactions::QuickAddsController < ApplicationController
  def create
    transaction = current_user.transactions.build(quick_add_params.merge(kind: "expense", occurred_on: Date.current))

    if transaction.save
      redirect_to dashboard_path, notice: "Added #{transaction.description} " \
        "(#{transaction.category&.name || "uncategorised"})."
    else
      redirect_to dashboard_path, alert: transaction.errors.full_messages.to_sentence
    end
  end

  private

  def quick_add_params
    params.require(:quick_add).permit(:amount, :description, :account_id)
  end
end

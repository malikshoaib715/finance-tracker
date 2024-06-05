# Applies one change to many of the user's transactions at once.
class Transactions::BulksController < ApplicationController
  before_action :set_transactions

  def update
    category = current_user.categories.find_by(id: params[:category_id])
    matching = category ? @transactions.where(kind: category.kind) : @transactions
    updated = matching.update_all(category_id: category&.id, updated_at: Time.current)

    skipped = @transactions.size - updated
    notice = "Updated #{helpers.pluralize(updated, "transaction")}."
    notice += " #{skipped} skipped: #{category.name} is an #{category.kind} category." if skipped.positive? && category
    redirect_back_or_to transactions_path, notice: notice
  end

  def destroy
    count = @transactions.size
    @transactions.includes(:receipts_attachments).destroy_all
    redirect_back_or_to transactions_path, notice: "Deleted #{helpers.pluralize(count, "transaction")}.", status: :see_other
  end

  private

  def set_transactions
    @transactions = current_user.transactions.where(id: Array(params[:transaction_ids]))
    redirect_back_or_to transactions_path, alert: "Select some transactions first." if @transactions.none?
  end
end

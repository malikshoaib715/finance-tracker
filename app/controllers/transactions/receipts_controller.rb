class Transactions::ReceiptsController < ApplicationController
  def destroy
    transaction = current_user.transactions.find(params[:transaction_id])
    receipt = transaction.receipts.find(params[:id])
    receipt.purge_later

    redirect_to edit_transaction_path(transaction), notice: "Receipt removed.", status: :see_other
  end
end

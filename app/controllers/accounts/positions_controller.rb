class Accounts::PositionsController < ApplicationController
  def update
    account = current_user.accounts.find(params[:account_id])
    account.move(params[:direction] == "up" ? -1 : 1)
    redirect_to accounts_path, status: :see_other
  end
end

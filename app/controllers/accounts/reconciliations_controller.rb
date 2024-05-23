class Accounts::ReconciliationsController < ApplicationController
  before_action :set_account

  def new
    @reconciliation = Account::Reconciliation.new(account: @account, actual_balance: @account.balance_cents / 100.0)
  end

  def create
    @reconciliation = Account::Reconciliation.new(account: @account, **params.require(:reconciliation).permit(:actual_balance, :on).to_h.symbolize_keys)
    result = @reconciliation.save

    if result == false
      render :new, status: :unprocessable_entity
    else
      notice = result ? "Recorded an adjustment of #{helpers.money(result.signed_amount_cents, @account.currency)}." : "Balance already matches."
      redirect_to account_path(@account), notice: notice
    end
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:account_id])
  end
end

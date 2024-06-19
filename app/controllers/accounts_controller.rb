class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show edit update destroy ]

  def index
    @accounts = current_user.accounts.active.ordered.with_balances
    @archived_accounts = current_user.accounts.archived.alphabetical
  end

  def show
    @ledger = @account.ledger.reverse
  end

  def new
    @account = current_user.accounts.build(currency: current_user.currency)
  end

  def create
    @account = current_user.accounts.build(account_params)

    if @account.save
      redirect_to accounts_path, notice: "#{@account.name} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: "#{@account.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @account.destroy
      redirect_to accounts_path, notice: "#{@account.name} was deleted.", status: :see_other
    else
      redirect_to edit_account_path(@account), alert: "#{@account.name} has history and can only be archived."
    end
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :kind, :currency, :opening_balance)
  end
end

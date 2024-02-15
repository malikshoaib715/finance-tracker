class AccountsController < ApplicationController
  before_action :set_account, only: %i[ edit update ]

  def index
    @accounts = current_user.accounts.active.alphabetical
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

  private

  def set_account
    @account = current_user.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :kind, :currency, :opening_balance)
  end
end

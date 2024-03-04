class TransfersController < ApplicationController
  before_action :set_transfer, only: %i[ edit update destroy ]
  before_action :load_accounts, only: %i[ new create edit update ]

  def new
    @transfer = current_user.transfers.build(occurred_on: Date.current,
      from_account: @accounts.first, to_account: @accounts.second)
  end

  def create
    @transfer = current_user.transfers.build(transfer_params)

    if @transfer.save
      redirect_to transactions_path, notice: "Transfer recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transfer.update(transfer_params)
      redirect_to transactions_path, notice: "Transfer updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transfer.destroy
    redirect_to transactions_path, notice: "Transfer deleted.", status: :see_other
  end

  private

  def set_transfer
    @transfer = current_user.transfers.find(params[:id])
  end

  def load_accounts
    @accounts = current_user.accounts.active.alphabetical
  end

  def transfer_params
    params.require(:transfer).permit(:from_account_id, :to_account_id, :amount, :occurred_on, :description)
  end
end

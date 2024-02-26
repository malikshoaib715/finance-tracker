class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ edit update destroy ]
  before_action :load_form_options, only: %i[ new create edit update ]

  def index
    @transactions = current_user.transactions.includes(:account, :category).recent_first.limit(100)
  end

  def new
    @transaction = current_user.transactions.build(
      occurred_on: Date.current,
      kind: params[:kind].presence_in(Transaction.kinds.keys) || "expense",
      account: @accounts.first
    )
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: "Transaction updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_path, notice: "Transaction deleted.", status: :see_other
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def load_form_options
    @accounts = current_user.accounts.active.alphabetical
    @categories = current_user.categories.alphabetical
  end

  def transaction_params
    params.require(:transaction).permit(:kind, :amount, :occurred_on, :description, :account_id, :category_id, :notes)
  end
end

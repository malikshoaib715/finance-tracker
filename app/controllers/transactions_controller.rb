class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ edit update destroy ]
  before_action :load_form_options, only: %i[ new create edit update ]

  def index
    @filter = TransactionFilter.new(current_user, filter_params)
    @accounts = current_user.accounts.alphabetical
    @categories = current_user.categories.alphabetical
    @tags = current_user.tags.alphabetical

    transactions = @filter.transactions.includes(:tags, :receipts_attachments).recent_first
    transfers = @filter.transfers.recent_first
    @totals = @filter.totals
    @entries = (transactions + transfers).sort_by { |entry| [ entry.occurred_on, entry.created_at ] }.reverse
  end

  def export
    filter = TransactionFilter.new(current_user, filter_params)
    csv = Transaction::CsvExport.new(filter.transactions).to_csv
    send_data csv, filename: "transactions-#{filter.period.first.strftime('%Y-%m')}.csv", type: :csv
  end

  def new
    @transaction =
      if (source = current_user.transactions.find_by(id: params[:repeat]))
        source.dup.tap { |copy| copy.occurred_on = Date.current }
      else
        current_user.transactions.build(
          occurred_on: Date.current,
          kind: params[:kind].presence_in(Transaction.kinds.keys) || "expense",
          account: @accounts.first
        )
      end
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

  def filter_params
    params.fetch(:filter, {}).permit(:q, :account_id, :category_id, :tag_id, :kind, :from, :to, :month)
  end

  def transaction_params
    params.require(:transaction).permit(:kind, :amount, :occurred_on, :description, :account_id, :category_id, :notes, :tag_list, receipts: [])
  end
end

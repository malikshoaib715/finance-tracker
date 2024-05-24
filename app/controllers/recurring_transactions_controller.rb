class RecurringTransactionsController < ApplicationController
  before_action :set_item, only: %i[ edit update destroy ]
  before_action :load_form_options, only: %i[ new create edit update ]

  def index
    @items = current_user.recurring_transactions.includes(:account).order(active: :desc, next_on: :asc)
  end

  def new
    @item = current_user.recurring_transactions.build(next_on: Date.current, account: @accounts.first)

    if (source = current_user.transactions.find_by(id: params[:from]))
      @item.assign_attributes(source.slice(:kind, :amount_cents, :description, :account_id, :category_id))
      @item.next_on = source.occurred_on.next_month
    end
  end

  def create
    @item = current_user.recurring_transactions.build(item_params)

    if @item.save
      redirect_to recurring_transactions_path, notice: "#{@item.description} will repeat #{@item.frequency}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to recurring_transactions_path, notice: "#{@item.description} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to recurring_transactions_path, notice: "#{@item.description} won't repeat any more.", status: :see_other
  end

  private

  def set_item
    @item = current_user.recurring_transactions.find(params[:id])
  end

  def load_form_options
    @accounts = current_user.accounts.active.alphabetical
    @categories = current_user.categories.alphabetical
  end

  def item_params
    params.require(:recurring_transaction).permit(:kind, :amount, :description, :account_id, :category_id,
                                                  :frequency, :next_on, :ends_on, :active)
  end
end

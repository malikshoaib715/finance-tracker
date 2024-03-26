class BudgetsController < ApplicationController
  before_action :set_budget, only: %i[ edit update destroy ]
  before_action :load_categories, only: %i[ new create edit update ]

  def index
    @month = parse_month(params[:month])
    @budgets = current_user.budgets.for_month(@month).includes(:category).sort_by { |b| b.category.name }
  end

  def new
    @budget = current_user.budgets.build(month: parse_month(params[:month]))
  end

  def create
    @budget = current_user.budgets.build(budget_params)

    if @budget.save
      redirect_to budgets_path(month: month_param(@budget.month)), notice: "Budget for #{@budget.category.name} saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @budget.update(budget_params)
      redirect_to budgets_path(month: month_param(@budget.month)), notice: "Budget for #{@budget.category.name} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @budget.destroy
    redirect_to budgets_path(month: month_param(@budget.month)), notice: "Budget removed.", status: :see_other
  end

  private

  def set_budget
    @budget = current_user.budgets.find(params[:id])
  end

  def load_categories
    @categories = current_user.categories.expense.alphabetical
  end

  def budget_params
    params.require(:budget).permit(:category_id, :amount, :month)
  end

  def parse_month(value)
    Date.strptime(value.to_s, "%Y-%m")
  rescue Date::Error
    Date.current.beginning_of_month
  end

  def month_param(date) = date.strftime("%Y-%m")
end

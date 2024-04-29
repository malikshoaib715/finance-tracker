class RulesController < ApplicationController
  before_action :set_rule, only: %i[ edit update destroy ]
  before_action :load_categories, only: %i[ index create edit update ]

  def index
    @rules = current_user.rules.includes(:category).order(:pattern)
    @rule = current_user.rules.build
    @uncategorised_count = current_user.transactions.where(category_id: nil).count
  end

  def create
    @rule = current_user.rules.build(rule_params)

    if @rule.save
      redirect_to rules_path, notice: "Rule added."
    else
      @rules = current_user.rules.includes(:category).order(:pattern)
      @uncategorised_count = current_user.transactions.where(category_id: nil).count
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @rule.update(rule_params)
      redirect_to rules_path, notice: "Rule updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rule.destroy
    redirect_to rules_path, notice: "Rule removed.", status: :see_other
  end

  private

  def set_rule
    @rule = current_user.rules.find(params[:id])
  end

  def load_categories
    @categories = current_user.categories.alphabetical
  end

  def rule_params
    params.require(:rule).permit(:pattern, :category_id)
  end
end

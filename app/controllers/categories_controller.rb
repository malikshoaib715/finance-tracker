class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ edit update destroy ]

  def index
    categories = current_user.categories.alphabetical
    @expense_categories = categories.expense
    @income_categories = categories.income
  end

  def new
    @category = current_user.categories.build(kind: params[:kind].presence_in(Category.kinds.keys) || "expense")
  end

  def create
    @category = current_user.categories.build(category_params)

    if @category.save
      redirect_to categories_path, notice: "#{@category.name} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "#{@category.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: "#{@category.name} was deleted.", status: :see_other
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :kind, :color)
  end
end

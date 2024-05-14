class GoalsController < ApplicationController
  before_action :set_goal, only: %i[ edit update destroy ]
  before_action :load_accounts, only: %i[ new create edit update ]

  def index
    @goals = current_user.goals.includes(:account).order(:target_on, :name)
  end

  def new
    @goal = current_user.goals.build
  end

  def create
    @goal = current_user.goals.build(goal_params)

    if @goal.save
      redirect_to goals_path, notice: "Goal “#{@goal.name}” added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @goal.update(goal_params)
      redirect_to goals_path, notice: "Goal “#{@goal.name}” updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy
    redirect_to goals_path, notice: "Goal removed.", status: :see_other
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:id])
  end

  def load_accounts
    @accounts = current_user.accounts.active.alphabetical
  end

  def goal_params
    params.require(:goal).permit(:name, :target, :saved, :target_on, :account_id)
  end
end

class Budgets::CopiesController < ApplicationController
  def create
    month = Date.strptime(params[:month].to_s, "%Y-%m")
    copied = Budget.copy_previous_month(current_user, month)

    notice = copied.any? ? "Copied #{copied.size} #{"budget".pluralize(copied.size)} from #{l(month.prev_month, format: "%B")}." : "Nothing new to copy."
    redirect_to budgets_path(month: params[:month]), notice: notice
  rescue Date::Error
    redirect_to budgets_path, alert: "Unknown month."
  end
end

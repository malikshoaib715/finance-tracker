class ReportsController < ApplicationController
  def show
    @cash_flow = Reports::MonthlyCashFlow.new(current_user)
    @net_worth = Reports::NetWorth.new(current_user)
    @month = selected_month
    @breakdown = Reports::CategoryBreakdown.new(current_user, month: @month)
  end

  private

  def selected_month
    month = Date.strptime(params[:month].to_s, "%Y-%m")
    month > Date.current ? Date.current.beginning_of_month : month
  rescue Date::Error
    Date.current.beginning_of_month
  end
end

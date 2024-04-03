class ReportsController < ApplicationController
  def show
    @cash_flow = Reports::MonthlyCashFlow.new(current_user)
    @breakdown = Reports::CategoryBreakdown.new(current_user)
  end
end

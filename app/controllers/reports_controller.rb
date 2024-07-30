class ReportsController < ApplicationController
  def show
    # Cache the numbers, not the HTML: chart tags carry a per-request CSP nonce.
    cache_key = [ current_user, :reports, current_user.finance_cache_version ]
    @cash_flow_data, @net_worth_series = Rails.cache.fetch(cache_key) do
      [ Reports::MonthlyCashFlow.new(current_user).chart_data, Reports::NetWorth.new(current_user).series ]
    end
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

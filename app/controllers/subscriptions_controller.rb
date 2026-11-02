class SubscriptionsController < ApplicationController
  def index
    current_user.regenerate_receipts_token unless current_user.receipts_token
    subscriptions = current_user.subscriptions.includes(:events).by_service.to_a
    @current = subscriptions.select { |s| s.active? || s.failing? || s.trial? }
    @ended = subscriptions.select(&:canceled?)
    @monthly_totals = @current.select(&:monthly_cents).group_by(&:currency)
                              .transform_values { |list| list.sum(&:monthly_cents) }
    @alerts = Subscriptions::Alerts.new(@current).to_a
  end
end

class Api::V1::SubscriptionsController < Api::V1::BaseController
  def index
    subscriptions = current_user.subscriptions.includes(:events).by_service
    render json: {
      subscriptions: subscriptions.map do |s|
        s.slice(:id, :service, :plan, :amount_cents, :currency, :interval, :status, :billed_via, :card_last4,
                :last_charged_on, :next_renewal_on).merge(monthly_cents: s.monthly_cents)
      end,
      alerts: Subscriptions::Alerts.new(subscriptions.reject(&:canceled?)).to_a.map(&:to_h)
    }
  end
end

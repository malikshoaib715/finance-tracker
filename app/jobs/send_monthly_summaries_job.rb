class SendMonthlySummariesJob < ApplicationJob
  queue_as :default

  # Queues last month's summary for every confirmed user who wants one.
  def perform(month: Date.current.prev_month)
    User.where(monthly_summary: true).where.not(confirmed_at: nil).find_each do |user|
      SummaryMailer.monthly(user, month: month).deliver_later
    end
  end
end

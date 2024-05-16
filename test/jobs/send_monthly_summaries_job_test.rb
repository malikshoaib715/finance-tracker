require "test_helper"

class SendMonthlySummariesJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "queues a summary for each confirmed user who wants one" do
    users(:bilal).update!(monthly_summary: false)

    assert_enqueued_emails 1 do
      SendMonthlySummariesJob.perform_now
    end
  end

  test "is scheduled for the 1st of the month" do
    assert_equal "0 8 1 * *", Rails.application.config.good_job.cron.dig(:monthly_summaries, :cron)
  end
end

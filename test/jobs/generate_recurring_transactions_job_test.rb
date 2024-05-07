require "test_helper"

class GenerateRecurringTransactionsJobTest < ActiveJob::TestCase
  test "records due recurring transactions" do
    assert_difference "Transaction.count", 1 do
      GenerateRecurringTransactionsJob.perform_now
    end
  end

  test "is scheduled daily via GoodJob cron" do
    entry = Rails.application.config.good_job.cron[:recurring_transactions]
    assert_equal "GenerateRecurringTransactionsJob", entry[:class]
  end
end

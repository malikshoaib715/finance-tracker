Rails.application.configure do
  config.good_job.execution_mode = :async
  config.good_job.enable_cron = true
  config.good_job.cron = {
    recurring_transactions: {
      cron: "15 1 * * *", # every day at 01:15 server time
      class: "GenerateRecurringTransactionsJob",
      description: "Record recurring transactions that have fallen due"
    }
  }
end

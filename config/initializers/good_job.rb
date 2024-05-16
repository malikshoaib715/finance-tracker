Rails.application.configure do
  config.good_job.execution_mode = :async
  config.good_job.enable_cron = true
  config.good_job.cron = {
    recurring_transactions: {
      cron: "15 1 * * *", # every day at 01:15 server time
      class: "GenerateRecurringTransactionsJob",
      description: "Record recurring transactions that have fallen due"
    },
    monthly_summaries: {
      cron: "0 8 1 * *", # 08:00 on the 1st of every month
      class: "SendMonthlySummariesJob",
      description: "Email last month's summary"
    }
  }
end

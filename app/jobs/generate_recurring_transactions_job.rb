class GenerateRecurringTransactionsJob < ApplicationJob
  queue_as :default

  def perform
    created = RecurringTransaction::Generator.run_due
    Rails.logger.info("[recurring] created #{created} transaction(s)")
  end
end

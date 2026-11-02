class SyncConnectedMailboxesJob < ApplicationJob
  queue_as :default

  def perform
    MailConnection.where.not(refresh_token: nil).find_each { GmailSyncJob.perform_later(_1.id) }
  end
end

# Tombstones only matter to clients that haven't synced since the deletion.
# After RETENTION, a client that far behind should do a full resync anyway.
class PruneDeletionsJob < ApplicationJob
  RETENTION = 90.days

  queue_as :default

  def perform
    Deletion.where(deleted_at: ...RETENTION.ago).in_batches(of: 5_000).delete_all
  end
end

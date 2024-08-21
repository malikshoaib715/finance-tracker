require "test_helper"

class PruneDeletionsJobTest < ActiveJob::TestCase
  test "removes tombstones older than the retention period" do
    user = users(:ayesha)
    old = user.deletions.create!(record_type: "Transaction", record_id: 1, deleted_at: 100.days.ago)
    recent = user.deletions.create!(record_type: "Transaction", record_id: 2, deleted_at: 10.days.ago)

    PruneDeletionsJob.perform_now

    assert_not Deletion.exists?(old.id)
    assert Deletion.exists?(recent.id)
  end
end

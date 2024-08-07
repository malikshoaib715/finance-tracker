# Tombstone left behind when a synced record is destroyed, so offline clients
# can remove their copy. Old tombstones can be pruned once clients have synced.
class Deletion < ApplicationRecord
  belongs_to :user

  scope :since, ->(time) { where(deleted_at: time..) }
end

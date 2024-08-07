module LeavesTombstone
  extend ActiveSupport::Concern

  included do
    after_destroy_commit -> { Deletion.create!(user_id:, record_type: self.class.name, record_id: id, deleted_at: Time.current) }
  end
end

# A user's connected mailbox (Gmail, read-only). Tokens are encrypted at rest
# with Active Record encryption and deleted when the user disconnects.
class MailConnection < ApplicationRecord
  belongs_to :user

  encrypts :access_token, :refresh_token

  validates :email, presence: true

  def expired?(margin: 60.seconds) = expires_at.nil? || expires_at <= margin.from_now
end

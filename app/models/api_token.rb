# A personal access token for the JSON API (e.g. the mobile app). Only a
# SHA-256 digest is stored; the plain token is shown once, at creation.
class ApiToken < ApplicationRecord
  PREFIX = "ft_"

  belongs_to :user

  attr_reader :plain_token

  normalizes :name, with: ->(name) { name.squish }
  validates :name, presence: true, length: { maximum: 60 }

  before_validation :generate_token, on: :create

  def self.digest(token) = OpenSSL::Digest::SHA256.hexdigest(token.to_s)

  # The token's user, or nil. Touches last_used_at at most once a minute.
  def self.authenticate(token)
    return if token.blank?

    api_token = find_by(token_digest: digest(token)) or return
    api_token.update_column(:last_used_at, Time.current) if api_token.last_used_at.nil? || api_token.last_used_at < 1.minute.ago
    api_token
  end

  private

  def generate_token
    @plain_token = PREFIX + SecureRandom.base58(32)
    self.token_digest = self.class.digest(@plain_token)
  end
end

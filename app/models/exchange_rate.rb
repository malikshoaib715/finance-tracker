# How many units of the user's default currency one unit of +currency+ is
# worth, e.g. USD -> 278.50 for a PKR user. Set by hand: no external feed.
class ExchangeRate < ApplicationRecord
  belongs_to :user

  validates :currency, inclusion: { in: User::CURRENCIES }, uniqueness: { scope: :user_id }
  validates :rate, numericality: { greater_than: 0 }
  validate :not_the_default_currency

  # Converts minor units in +currency+ to the user's default currency.
  # Returns nil when no rate is known.
  def self.convert(user, amount_cents, currency)
    return amount_cents if currency == user.currency

    rate = user.exchange_rates.find { |r| r.currency == currency }&.rate
    (amount_cents * rate).round if rate
  end

  private

  def not_the_default_currency
    errors.add(:currency, "is already your default currency") if user && currency == user.currency
  end
end

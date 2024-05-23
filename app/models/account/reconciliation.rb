# Brings the tracked balance in line with what the bank says by recording a
# single adjustment transaction for the difference.
class Account::Reconciliation
  include ActiveModel::Model

  attr_accessor :account, :on
  attr_reader :actual_balance
  validates :actual_balance, presence: true, numericality: true

  # Accept "1,234.50" like every other amount field.
  def actual_balance=(value)
    @actual_balance = value.is_a?(String) ? value.delete(",").strip : value
  end

  def difference_cents
    (BigDecimal(actual_balance.to_s) * 100).round - account.balance_cents
  end

  # Returns the adjustment transaction, or nil when the balance already matches.
  def save
    return false unless valid?
    return nil if difference_cents.zero?

    account.user.transactions.create!(
      account: account, kind: difference_cents.positive? ? "income" : "expense",
      amount_cents: difference_cents.abs, occurred_on: on.presence || Date.current,
      description: "Balance adjustment", notes: "Reconciled to #{actual_balance} on #{Date.current.iso8601}"
    )
  end
end

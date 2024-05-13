# Something to save towards. Progress follows a linked account's balance, or
# an amount the user updates by hand when no account is linked.
class Goal < ApplicationRecord
  belongs_to :user
  belongs_to :account, optional: true

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 60 }
  validates :target_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :saved_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :account_belongs_to_user

  %i[ target saved ].each do |field|
    define_method(field) { public_send(:"#{field}_cents").to_i / 100.0 }
    define_method(:"#{field}=") do |value|
      public_send(:"#{field}_cents=", (BigDecimal(value.to_s.delete(",").presence || "0") * 100).round)
    rescue ArgumentError
      public_send(:"#{field}_cents=", nil)
    end
  end

  def progress_cents
    account ? [ account.balance_cents, 0 ].max : saved_cents
  end

  def remaining_cents
    [ target_cents - progress_cents, 0 ].max
  end

  def ratio
    [ progress_cents.fdiv(target_cents), 1.0 ].min
  end

  def reached?
    progress_cents >= target_cents
  end

  # How much to put aside each month from now to hit the target date.
  def monthly_needed_cents(today: Date.current)
    return if target_on.nil? || reached?

    months = ((target_on.year * 12 + target_on.month) - (today.year * 12 + today.month)).clamp(1..)
    (remaining_cents.to_f / months).ceil
  end

  private

  def account_belongs_to_user
    errors.add(:account, "is not one of yours") if account && account.user_id != user_id
  end
end

class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :category, optional: true
  has_many :taggings, foreign_key: :transaction_id, inverse_of: :owner_transaction, dependent: :delete_all
  has_many :tags, through: :taggings
  has_many_attached :receipts

  RECEIPT_TYPES = %w[image/jpeg image/png image/webp image/heic application/pdf].freeze
  RECEIPT_MAX_SIZE = 5.megabytes

  enum :kind, { expense: "expense", income: "income" }, default: :expense, validate: true

  normalizes :description, with: ->(description) { description.squish }

  validates :description, presence: true, length: { maximum: 120 }
  validates :occurred_on, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validate :account_and_category_belong_to_user
  validate :category_matches_kind
  validate :receipts_are_images_or_pdfs

  scope :recent_first, -> { order(occurred_on: :desc, id: :desc) }

  # Signed effect on the account balance: income adds, expenses subtract.
  def signed_amount_cents
    income? ? amount_cents : -amount_cents
  end

  def amount
    amount_cents.to_i / 100.0 if amount_cents
  end

  def amount=(value)
    self.amount_cents = (BigDecimal(value.to_s.delete(",")) * 100).round.abs
  rescue ArgumentError, TypeError
    self.amount_cents = nil
  end

  # The budget this expense counts against, if one is set for its month.
  def budget
    return unless expense? && category_id

    user.budgets.find_by(category_id: category_id, month: occurred_on.beginning_of_month)
  end

  def tag_list
    tags.map(&:name).join(", ")
  end

  # "groceries, Family , #ramadan" -> the user's tags, created as needed.
  def tag_list=(value)
    names = value.to_s.split(",").map { |name| name.squish.downcase.delete_prefix("#") }.compact_blank.uniq
    self.tags = names.map { |name| user.tags.find_or_initialize_by(name: name) }
  end

  private

  def account_and_category_belong_to_user
    errors.add(:account, "is not one of yours") if account && account.user_id != user_id
    errors.add(:category, "is not one of yours") if category && category.user_id != user_id
  end

  def category_matches_kind
    return if category.nil? || category.kind == kind

    errors.add(:category, "is for #{category.kind.pluralize}, not #{kind.pluralize}")
  end

  def receipts_are_images_or_pdfs
    receipts.each do |receipt|
      unless receipt.content_type.in?(RECEIPT_TYPES)
        errors.add(:receipts, "must be images or PDFs (#{receipt.filename} isn't)")
      end
      if receipt.byte_size > RECEIPT_MAX_SIZE
        errors.add(:receipts, "must be smaller than 5 MB (#{receipt.filename} is too big)")
      end
    end
  end
end

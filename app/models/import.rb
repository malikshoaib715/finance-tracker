require "csv"

# A bank statement uploaded as CSV, mapped to our columns and turned into
# transactions on one account.
class Import < ApplicationRecord
  MAX_SIZE = 1.megabyte

  belongs_to :user
  belongs_to :account

  enum :status, { uploaded: "uploaded", mapped: "mapped", completed: "completed" }, default: :uploaded

  validates :filename, presence: true
  validates :raw_csv, presence: true, length: { maximum: MAX_SIZE, too_long: "is too big (1 MB maximum)" }
  validate :account_belongs_to_user
  validate :csv_is_readable, if: :raw_csv?

  scope :recent_first, -> { order(created_at: :desc) }

  def file=(upload)
    return if upload.blank?

    self.filename = upload.original_filename
    self.raw_csv = upload.read.force_encoding("UTF-8").scrub.delete_prefix("\uFEFF")
  end

  def headers
    table.headers.compact
  end

  def table
    @table ||= CSV.parse(raw_csv, headers: true, skip_blanks: true)
  end

  private

  def account_belongs_to_user
    errors.add(:account, "is not one of yours") if account && account.user_id != user_id
  end

  def csv_is_readable
    errors.add(:file, "has no header row") if headers.empty?
  rescue CSV::MalformedCSVError => e
    errors.add(:file, "isn't a valid CSV (#{e.message})")
  end
end

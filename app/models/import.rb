require "csv"

# A bank statement uploaded as CSV, mapped to our columns and turned into
# transactions on one account.
class Import < ApplicationRecord
  MAX_SIZE = 1.megabyte
  DATE_FORMATS = { "%d/%m/%Y" => "31/12/2024", "%m/%d/%Y" => "12/31/2024", "%Y-%m-%d" => "2024-12-31",
                   "%d-%m-%Y" => "31-12-2024", "%d %b %Y" => "31 Dec 2024" }.freeze
  AMOUNT_MODES = { "single" => "One amount column (negative = money out)", "split" => "Separate debit and credit columns" }.freeze

  belongs_to :user
  belongs_to :account

  enum :status, { uploaded: "uploaded", mapped: "mapped", completed: "completed" }, default: :uploaded

  store_accessor :mapping, :date_column, :description_column, :amount_mode, :amount_column,
                 :debit_column, :credit_column, :date_format

  validates :filename, presence: true
  validates :raw_csv, presence: true, length: { maximum: MAX_SIZE, too_long: "is too big (1 MB maximum)" }
  validate :account_belongs_to_user
  validate :csv_is_readable, if: :raw_csv?
  validate :mapping_is_complete, if: :mapped?

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

  # Best guesses from common bank header names, used to pre-fill the mapping form.
  def suggest_mapping
    find = ->(*words) { headers.find { |h| words.any? { |w| h.to_s.downcase.include?(w) } } }
    debit, credit = find.("debit", "withdrawal", "money out"), find.("credit", "deposit", "money in")

    self.date_column ||= find.("date")
    self.description_column ||= find.("description", "narration", "details", "particulars", "memo")
    self.amount_mode ||= debit && credit ? "split" : "single"
    self.debit_column ||= debit
    self.credit_column ||= credit
    self.amount_column ||= find.("amount")
    self.date_format ||= DATE_FORMATS.keys.first
    self
  end

  private

  def mapping_is_complete
    required = [ :date_column, :description_column ] +
      (amount_mode == "split" ? [ :debit_column, :credit_column ] : [ :amount_column ])
    required.each do |column|
      errors.add(column, "must be one of the file's columns") unless public_send(column).in?(headers)
    end
    errors.add(:amount_mode, "is not recognised") unless amount_mode.in?(AMOUNT_MODES.keys)
    errors.add(:date_format, "is not recognised") unless date_format.in?(DATE_FORMATS.keys)
  end

  def account_belongs_to_user
    errors.add(:account, "is not one of yours") if account && account.user_id != user_id
  end

  def csv_is_readable
    errors.add(:file, "has no header row") if headers.empty?
  rescue CSV::MalformedCSVError => e
    errors.add(:file, "isn't a valid CSV (#{e.message})")
  end
end

# Turns the mapped CSV into Import::Row objects and flags rows that already
# exist on the account (same date, amount, kind and description).
class Import::Parser
  def initialize(import)
    @import = import
  end

  def rows
    @rows ||= flag_duplicates(@import.table.each.with_index(2).map { |record, line| parse(record, line) })
  end

  private

  def parse(record, line)
    errors = []
    date = parse_date(record[@import.date_column], errors)
    description = record[@import.description_column].to_s.squish
    errors << "description is empty" if description.blank?
    amount = parse_amount(record, errors)

    Import::Row.new(line:, occurred_on: date, description: description.truncate(120), amount_cents: amount, errors:)
  end

  def parse_date(value, errors)
    Date.strptime(value.to_s.strip, @import.date_format)
  rescue Date::Error
    errors << "date #{value.inspect} doesn't match #{Import::DATE_FORMATS[@import.date_format]}"
    nil
  end

  # Returns signed minor units: negative for money out.
  def parse_amount(record, errors)
    cents =
      if @import.amount_mode == "split"
        to_cents(record[@import.credit_column]).to_i - to_cents(record[@import.debit_column]).to_i
      else
        to_cents(record[@import.amount_column])
      end

    errors << "amount is missing or zero" if cents.to_i.zero?
    cents
  rescue ArgumentError
    errors << "amount isn't a number"
    nil
  end

  # "1,234.50", "(1,234.50)", "-1234.5", "1234.50 DR" -> signed cents
  def to_cents(value)
    text = value.to_s.strip
    return if text.empty?

    negative = text.start_with?("-", "(") || text.match?(/\bdr\z/i)
    number = BigDecimal(text.gsub(/[^\d.]/, ""))
    cents = (number * 100).round
    negative ? -cents : cents
  end

  def flag_duplicates(rows)
    dates = rows.filter_map(&:occurred_on)
    return rows if dates.empty?

    existing = @import.account.transactions.where(occurred_on: dates.min..dates.max)
      .pluck(:occurred_on, :amount_cents, :kind, :description)
      .to_set { |date, cents, kind, desc| [ date, cents, kind, desc.downcase ] }

    rows.each do |row|
      row.duplicate = existing.include?([ row.occurred_on, row.amount_cents, row.kind, row.description.downcase ])
    end
  end
end

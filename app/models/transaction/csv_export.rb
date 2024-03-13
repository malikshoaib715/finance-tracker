require "csv"

class Transaction::CsvExport
  HEADERS = %w[Date Type Description Account Category Amount Currency Notes].freeze

  def initialize(transactions)
    @transactions = transactions
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADERS
      @transactions.includes(:account, :category).reorder(:occurred_on, :id).each do |t|
        csv << [ t.occurred_on.iso8601, t.kind, t.description, t.account.name, t.category&.name,
                 format("%.2f", t.signed_amount_cents / 100.0), t.account.currency, t.notes ]
      end
    end
  end
end

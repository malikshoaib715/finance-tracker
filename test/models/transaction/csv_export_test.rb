require "test_helper"

class Transaction::CsvExportTest < ActiveSupport::TestCase
  test "exports signed amounts in date order" do
    rows = CSV.parse(Transaction::CsvExport.new(users(:ayesha).transactions).to_csv, headers: true)

    assert_equal %w[February\ salary Flat\ rent Imtiaz\ weekly\ shop], rows.map { |r| r["Description"] }
    assert_equal %w[250000.00 -65000.00 -4350.00], rows.map { |r| r["Amount"] }
    assert_equal "Groceries", rows[-1]["Category"]
  end
end

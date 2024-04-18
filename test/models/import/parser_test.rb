require "test_helper"

class Import::ParserTest < ActiveSupport::TestCase
  def import(csv, **mapping)
    users(:ayesha).imports.create!(account: accounts(:ayesha_bank), filename: "s.csv", raw_csv: csv).tap do |import|
      import.update!({ status: "mapped", date_column: "Date", description_column: "Details",
                       amount_mode: "single", amount_column: "Amount", date_format: "%d/%m/%Y" }.merge(mapping))
    end
  end

  test "parses dates, signed amounts and descriptions" do
    rows = import("Date,Details,Amount\n03/04/2024,Imtiaz,\"-4,350.00\"\n05/04/2024,Salary,\"250,000\"\n").rows

    assert_equal [ Date.new(2024, 4, 3), Date.new(2024, 4, 5) ], rows.map(&:occurred_on)
    assert_equal [ [ "expense", 435_000 ], [ "income", 25_000_000 ] ], rows.map { |r| [ r.kind, r.amount_cents ] }
    assert rows.all?(&:importable?)
  end

  test "understands brackets and DR as money out" do
    rows = import("Date,Details,Amount\n01/04/2024,Fee,(150.00)\n02/04/2024,Card,99.50 DR\n").rows
    assert_equal %w[expense expense], rows.map(&:kind)
  end

  test "reads separate debit and credit columns" do
    csv = file_fixture("meezan_statement.csv").read
    rows = import(csv, description_column: "Narration", amount_mode: "split", debit_column: "Debit", credit_column: "Credit").rows
    assert_equal [ -435_000, 25_000_000, -812_050 ], rows.map(&:signed_amount_cents)
  end

  test "reports rows it can't read, with their line numbers" do
    rows = import("Date,Details,Amount\n2024-04-03,Odd date,10\n04/04/2024,,abc\n").rows

    assert_equal [ 2, 3 ], rows.map(&:line)
    assert_match "doesn't match", rows.first.errors.first
    assert_includes rows.second.errors, "description is empty"
    assert_not rows.any?(&:importable?)
  end

  test "flags rows already recorded on the account" do
    date = transactions(:rent).occurred_on.strftime("%d/%m/%Y")
    rows = import("Date,Details,Amount\n#{date},flat rent,-65000\n").rows
    assert rows.first.duplicate?
  end
end

require "test_helper"

class ImportTest < ActiveSupport::TestCase
  def upload(name = "meezan_statement.csv")
    Rack::Test::UploadedFile.new(file_fixture(name), "text/csv")
  end

  test "reads headers and rows from the uploaded file" do
    import = users(:ayesha).imports.create!(account: accounts(:ayesha_bank), file: upload)
    assert_equal "meezan_statement.csv", import.filename
    assert_equal %w[Date Narration Debit Credit Balance], import.headers
    assert_equal 3, import.table.size
  end

  test "rejects files that aren't CSV" do
    import = users(:ayesha).imports.build(account: accounts(:ayesha_bank), filename: "x.csv", raw_csv: "\"unclosed,quote\n")
    assert_not import.valid?
    assert_match "isn't a valid CSV", import.errors[:file].first
  end

  test "account must belong to the user" do
    assert_not users(:ayesha).imports.build(account: accounts(:bilal_bank), file: upload).valid?
  end

  test "suggests a mapping from common bank headers" do
    import = users(:ayesha).imports.create!(account: accounts(:ayesha_bank), file: upload).suggest_mapping
    assert_equal "Date", import.date_column
    assert_equal "Narration", import.description_column
    assert_equal "split", import.amount_mode
    assert_equal [ "Debit", "Credit" ], [ import.debit_column, import.credit_column ]
  end

  test "a mapped import needs real columns" do
    import = users(:ayesha).imports.create!(account: accounts(:ayesha_bank), file: upload)
    import.assign_attributes(status: "mapped", date_column: "Nope", description_column: "Narration",
                             amount_mode: "single", amount_column: "Debit", date_format: "%d/%m/%Y")
    assert_not import.valid?
    assert import.errors[:date_column].any?
  end

  test "running and undoing an import" do
    import = users(:ayesha).imports.create!(account: accounts(:ayesha_bank), file: upload)
    import.update!(status: "mapped", date_column: "Date", description_column: "Narration",
      amount_mode: "split", debit_column: "Debit", credit_column: "Credit", date_format: "%d/%m/%Y")

    assert_difference "Transaction.count", 3 do
      import.run!
    end
    assert_equal [ 3, 0 ], [ import.imported_count, import.skipped_count ]

    assert_difference "Transaction.count", -3 do
      import.undo!
    end
    assert import.undone?
  end

  test "re-running the same statement skips everything as duplicates" do
    first, second = 2.times.map do
      users(:ayesha).imports.create!(account: accounts(:ayesha_bank), file: upload).tap do |import|
        import.update!(status: "mapped", date_column: "Date", description_column: "Narration",
          amount_mode: "split", debit_column: "Debit", credit_column: "Credit", date_format: "%d/%m/%Y")
      end
    end
    first.run!
    second.run!
    assert_equal [ 0, 3 ], [ second.imported_count, second.skipped_count ]
  end
end

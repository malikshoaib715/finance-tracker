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
end

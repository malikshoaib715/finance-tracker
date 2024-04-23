require "application_system_test_case"

class ImportsTest < ApplicationSystemTestCase
  setup { login_as users(:ayesha) }

  test "importing a bank statement end to end" do
    visit transactions_path
    click_on "Import"

    select "Meezan Current", from: "Import into"
    attach_file "CSV file", file_fixture("meezan_statement.csv")
    click_on "Upload"

    assert_text "3 rows into Meezan Current"
    assert_select "Description", selected: "Narration"
    assert_checked_field "Separate debit and credit columns"
    assert_no_selector "#import_amount_column"
    click_on "Preview"

    assert_text "3 transactions ready for Meezan Current"
    assert_text "K-ELECTRIC BILL"
    click_on "Import 3 transactions"

    assert_text "Imported 3 transactions."
  end
end

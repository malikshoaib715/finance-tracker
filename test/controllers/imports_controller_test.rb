require "test_helper"

class ImportsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "uploads a statement and moves on to mapping" do
    assert_difference "Import.count" do
      post imports_url, params: { import: { account_id: accounts(:ayesha_bank).id,
        file: fixture_file_upload("meezan_statement.csv", "text/csv") } }
    end
    assert_redirected_to edit_import_url(Import.last)

    follow_redirect!
    assert_select "p", /3 rows into/
  end

  test "lists past imports" do
    get imports_url
    assert_response :success
  end

  test "saves the column mapping" do
    import = users(:ayesha).imports.create!(account: accounts(:ayesha_bank),
      file: fixture_file_upload("meezan_statement.csv", "text/csv"))

    get edit_import_url(import)
    assert_select "select#import_description_column option[selected]", "Narration"

    patch import_url(import), params: { import: { date_column: "Date", description_column: "Narration",
      amount_mode: "split", debit_column: "Debit", credit_column: "Credit", date_format: "%d/%m/%Y" } }
    assert_redirected_to import_url(import)
    assert import.reload.mapped?
  end
end

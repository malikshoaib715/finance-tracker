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
end

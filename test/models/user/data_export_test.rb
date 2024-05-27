require "test_helper"

class User::DataExportTest < ActiveSupport::TestCase
  test "includes the user's records and nobody else's" do
    data = User::DataExport.new(users(:ayesha)).as_json

    assert_equal "ayesha@example.com", data[:user]["email"]
    assert_equal 3, data[:accounts].size
    assert_equal 3, data[:transactions].size
    assert_equal [ "family" ], data[:transactions].find { |t| t["description"] == "Imtiaz weekly shop" }[:tags]
    assert_not_includes data[:transactions].map { |t| t["description"] }, "Al-Fatah"
  end
end

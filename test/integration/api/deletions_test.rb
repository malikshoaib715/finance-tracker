require "test_helper"

class Api::DeletionsTest < ActionDispatch::IntegrationTest
  AUTH = { "Authorization" => "Bearer ft_ayesha_test_token" }.freeze

  test "deleted transactions leave a tombstone clients can fetch" do
    started = Time.current
    delete api_v1_transaction_url(transactions(:rent)), headers: AUTH

    get api_v1_deletions_url(since: started.iso8601), headers: AUTH
    deletion = response.parsed_body["deletions"].sole
    assert_equal [ "Transaction", transactions(:rent).id ], deletion.values_at("record_type", "record_id")
  end

  test "only the user's own tombstones" do
    transactions(:bilal_groceries).destroy
    get api_v1_deletions_url, headers: AUTH
    assert_empty response.parsed_body["deletions"]
  end
end

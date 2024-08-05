require "test_helper"

class Api::AccountsAndCategoriesTest < ActionDispatch::IntegrationTest
  AUTH = { "Authorization" => "Bearer ft_ayesha_test_token" }.freeze

  test "lists the user's accounts with balances, in their order" do
    get api_v1_accounts_url, headers: AUTH
    accounts = response.parsed_body["accounts"]

    assert_equal [ "HBL Credit Card", "Meezan Current", "Wallet cash" ], accounts.map { |a| a["name"] }
    assert_equal accounts(:ayesha_bank).balance_cents, accounts.second["balance_cents"]
  end

  test "lists the user's categories only" do
    get api_v1_categories_url, headers: AUTH
    names = response.parsed_body["categories"].map { |c| c["name"] }
    assert_equal %w[Groceries Rent Salary], names
  end
end

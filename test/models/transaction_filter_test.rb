require "test_helper"

class TransactionFilterTest < ActiveSupport::TestCase
  def filter(params = {}) = TransactionFilter.new(users(:ayesha), params)

  test "no filter returns everything for the user" do
    assert_not filter.active?
    assert_equal 3, filter.transactions.count
    assert_equal 1, filter.transfers.count
  end

  test "searches descriptions case-insensitively" do
    assert_equal [ transactions(:groceries) ], filter(q: "IMTIAZ").transactions.to_a
  end

  test "escapes LIKE wildcards in the search" do
    assert_empty filter(q: "%").transactions
  end

  test "filters by account, including transfers on either side" do
    f = filter(account_id: accounts(:ayesha_cash).id)
    assert_equal [ transactions(:groceries) ], f.transactions.to_a
    assert_equal [ transfers(:atm_withdrawal) ], f.transfers.to_a
  end

  test "category and kind filters hide transfers" do
    f = filter(kind: "income")
    assert_equal [ transactions(:salary) ], f.transactions.to_a
    assert_empty f.transfers
  end

  test "filters by date range" do
    start = Date.current.beginning_of_month
    f = filter(from: start + 1, to: start + 3)
    assert_equal [ transactions(:rent), transactions(:groceries) ].sort_by(&:id), f.transactions.sort_by(&:id)
  end
end

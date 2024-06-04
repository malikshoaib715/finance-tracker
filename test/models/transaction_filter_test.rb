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

  test "defaults to the current month" do
    assert_equal Date.current.all_month, filter.period
  end

  test "can show another month" do
    old = users(:ayesha).transactions.create!(account: accounts(:ayesha_cash), kind: "expense",
      amount: "100", occurred_on: Date.new(2023, 12, 15), description: "Old purchase")

    assert_equal [ old ], filter(month: "2023-12").transactions.to_a
    assert_not_includes filter.transactions, old
  end

  test "an invalid month falls back to the current one" do
    assert_equal Date.current.all_month, filter(month: "nonsense").period
  end

  test "totals income, expenses and net for the filtered set" do
    assert_equal({ income: 25_000_000, expense: 6_935_000, net: 18_065_000 }, filter.totals)
    assert_equal({ income: 0, expense: 435_000, net: -435_000 }, filter(account_id: accounts(:ayesha_cash).id).totals)
  end

  test "filters by tag and hides transfers" do
    f = filter(tag_id: tags(:ayesha_family).id)
    assert_equal [ transactions(:groceries) ], f.transactions.to_a
    assert_empty f.transfers
  end

  test "search also looks in notes" do
    transactions(:rent).update!(notes: "Paid to landlord via IBFT")
    assert_equal [ transactions(:rent) ], filter(q: "landlord").transactions.to_a
  end
end

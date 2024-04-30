require "test_helper"

class RuleTest < ActiveSupport::TestCase
  test "finds a category by case-insensitive match" do
    assert_equal categories(:ayesha_groceries), Rule.category_for(users(:ayesha), "POS PURCHASE IMTIAZ SUPERMARKET", :expense)
    assert_nil Rule.category_for(users(:ayesha), "Careem ride", :expense)
  end

  test "only matches categories of the same kind" do
    assert_equal categories(:ayesha_salary), Rule.category_for(users(:ayesha), "Salary April", :income)
    assert_nil Rule.category_for(users(:ayesha), "Salary advance repayment", :expense)
  end

  test "prefers the longest matching pattern" do
    users(:ayesha).rules.create!(pattern: "imtiaz pharmacy", category: categories(:ayesha_rent))
    assert_equal categories(:ayesha_rent), Rule.category_for(users(:ayesha), "IMTIAZ PHARMACY GULBERG", :expense)
  end

  test "patterns are unique per user and need a category of theirs" do
    assert_not users(:ayesha).rules.build(pattern: "Imtiaz", category: categories(:ayesha_rent)).valid?
    assert_not users(:ayesha).rules.build(pattern: "al-fatah", category: categories(:bilal_groceries)).valid?
  end

  test "new transactions without a category are filed by rules" do
    transaction = users(:ayesha).transactions.create!(account: accounts(:ayesha_cash), kind: "expense",
      amount: "500", occurred_on: Date.current, description: "IMTIAZ express")
    assert_equal categories(:ayesha_groceries), transaction.category
  end

  test "rules never override a chosen category" do
    transaction = users(:ayesha).transactions.create!(account: accounts(:ayesha_cash), kind: "expense",
      category: categories(:ayesha_rent), amount: "500", occurred_on: Date.current, description: "Imtiaz")
    assert_equal categories(:ayesha_rent), transaction.category
  end

  test "imported rows are categorised by rules" do
    import = users(:ayesha).imports.create!(account: accounts(:ayesha_bank),
      file: Rack::Test::UploadedFile.new(file_fixture("meezan_statement.csv"), "text/csv"))
    import.update!(status: "mapped", date_column: "Date", description_column: "Narration",
      amount_mode: "split", debit_column: "Debit", credit_column: "Credit", date_format: "%d/%m/%Y")
    import.run!

    assert_equal [ "Groceries", "Salary", nil ],
      import.transactions.order(:occurred_on).map { |t| t.category&.name }
  end

  test "the matcher loads rules once for many descriptions" do
    user = users(:ayesha)
    queries = count_queries do
      matcher = Rule::Matcher.new(user)
      100.times { matcher.category_for("IMTIAZ #{_1}", :expense) }
    end
    assert_operator queries, :<=, 2
  end
end

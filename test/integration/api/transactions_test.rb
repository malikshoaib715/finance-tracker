require "test_helper"

class Api::TransactionsTest < ActionDispatch::IntegrationTest
  AUTH = { "Authorization" => "Bearer ft_ayesha_test_token" }.freeze

  test "lists only the user's transactions, oldest change first" do
    get api_v1_transactions_url, headers: AUTH
    body = response.parsed_body

    assert_equal 3, body["transactions"].size
    assert_nil body["next_cursor"]
    assert_not_includes body["transactions"].map { _1["description"] }, "Al-Fatah"
    assert_equal [ "family" ], body["transactions"].find { _1["description"] == "Imtiaz weekly shop" }["tags"]
  end

  test "returns only changes since a time" do
    Transaction.update_all(updated_at: 1.hour.ago)
    transactions(:rent).touch
    get api_v1_transactions_url(updated_since: 1.minute.ago.iso8601), headers: AUTH
    assert_equal [ "Flat rent" ], response.parsed_body["transactions"].map { _1["description"] }
  end

  test "pages with a cursor" do
    stub_const(Api::V1::TransactionsController, :PAGE_SIZE, 2) do
      get api_v1_transactions_url, headers: AUTH
      first = response.parsed_body
      assert_equal 2, first["transactions"].size

      get api_v1_transactions_url(cursor: first["next_cursor"]), headers: AUTH
      second = response.parsed_body
      assert_equal 1, second["transactions"].size
      assert_nil second["next_cursor"]
    end
  end

  test "rejects a bad timestamp" do
    get api_v1_transactions_url(updated_since: "yesterday"), headers: AUTH
    assert_response :bad_request
  end

  test "creates, updates and deletes" do
    post api_v1_transactions_url, headers: AUTH, as: :json, params: { transaction: {
      kind: "expense", amount_cents: 125_000, occurred_on: Date.current, description: "Careem",
      account_id: accounts(:ayesha_cash).id
    } }
    assert_response :created
    id = response.parsed_body["id"]

    patch api_v1_transaction_url(id), headers: AUTH, as: :json, params: { transaction: { description: "Careem ride" } }
    assert_equal "Careem ride", response.parsed_body["description"]

    delete api_v1_transaction_url(id), headers: AUTH
    assert_response :no_content
  end

  test "creating with a client_id is idempotent" do
    payload = { transaction: { client_id: "3f1c2b8e-8a8c-4f2e-9a51-0d9b8f1e2a77", kind: "expense", amount_cents: 5_000,
                               occurred_on: Date.current, description: "Chai", account_id: accounts(:ayesha_cash).id } }

    assert_difference "Transaction.count", 1 do
      post api_v1_transactions_url, headers: AUTH, as: :json, params: payload
      assert_response :created
      post api_v1_transactions_url, headers: AUTH, as: :json, params: payload
      assert_response :ok
    end
    assert_equal payload.dig(:transaction, :client_id), response.parsed_body["client_id"]
  end

  test "refuses a stale update with 409 and the server copy" do
    seen = transactions(:rent).updated_at
    travel 1.minute do
      transactions(:rent).update!(description: "Rent (edited on the web)")
    end

    patch api_v1_transaction_url(transactions(:rent)), headers: AUTH, as: :json,
          params: { if_unmodified_since: seen.iso8601(6), transaction: { description: "Rent (phone)" } }
    assert_response :conflict
    assert_equal "Rent (edited on the web)", response.parsed_body.dig("transaction", "description")

    patch api_v1_transaction_url(transactions(:rent)), headers: AUTH, as: :json,
          params: { if_unmodified_since: transactions(:rent).reload.updated_at.iso8601(6), transaction: { description: "Rent (phone)" } }
    assert_response :success
  end

  test "validation errors come back as 422 with details" do
    post api_v1_transactions_url, headers: AUTH, as: :json, params: { transaction: { kind: "expense", amount_cents: 0 } }
    assert_response :unprocessable_entity
    assert response.parsed_body.dig("error", "details", "description")
  end

  test "can't point a transaction at another user's account" do
    post api_v1_transactions_url, headers: AUTH, as: :json, params: { transaction: {
      kind: "expense", amount_cents: 100, occurred_on: Date.current, description: "x", account_id: accounts(:bilal_bank).id
    } }
    assert_response :not_found
  end

  test "another user's transaction is not found" do
    get api_v1_transaction_url(transactions(:bilal_groceries)), headers: AUTH
    assert_response :not_found
  end

  private

  def stub_const(klass, name, value)
    original = klass.const_get(name)
    klass.send(:remove_const, name)
    klass.const_set(name, value)
    yield
  ensure
    klass.send(:remove_const, name)
    klass.const_set(name, original)
  end
end

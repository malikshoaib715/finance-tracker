# Transactions for sync clients. GET returns changes since `updated_since`
# (ISO 8601) ordered by (updated_at, id) with an opaque cursor for the next page.
class Api::V1::TransactionsController < Api::V1::BaseController
  PAGE_SIZE = 200

  before_action :set_transaction, only: %i[ show update destroy ]

  def index
    scope = current_user.transactions.includes(:tags).reorder(:updated_at, :id)
    scope = scope.where(updated_at: Time.iso8601(params[:updated_since])..) if params[:updated_since].present?
    if (cursor = decode_cursor(params[:cursor]))
      scope = scope.where("(transactions.updated_at, transactions.id) > (?, ?)", cursor[:updated_at], cursor[:id])
    end

    page = scope.limit(PAGE_SIZE + 1).to_a
    more = page.size > PAGE_SIZE
    page = page.first(PAGE_SIZE)

    render json: { transactions: page.map { serialize(_1) }, next_cursor: (encode_cursor(page.last) if more) }
  rescue ArgumentError
    render_error(:bad_request, "updated_since must be an ISO 8601 time")
  end

  def show
    render json: serialize(@transaction)
  end

  def create
    transaction = current_user.transactions.build(transaction_params)
    if transaction.save
      render json: serialize(transaction), status: :created
    else
      render_invalid(transaction)
    end
  end

  def update
    if @transaction.update(transaction_params)
      render json: serialize(@transaction)
    else
      render_invalid(@transaction)
    end
  end

  def destroy
    @transaction.destroy!
    head :no_content
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  # Account and category ids are resolved through the current user, so a client
  # can only ever point a transaction at its own records.
  def transaction_params
    attrs = params.require(:transaction).permit(:kind, :amount_cents, :occurred_on, :description, :notes, :tag_list)
    raw = params[:transaction]
    attrs[:account] = current_user.accounts.find(raw[:account_id]) if raw.key?(:account_id)
    attrs[:category] = raw[:category_id].presence && current_user.categories.find(raw[:category_id]) if raw.key?(:category_id)
    attrs
  end

  def serialize(transaction)
    transaction.slice(:id, :account_id, :category_id, :kind, :amount_cents, :occurred_on, :description, :notes,
                      :created_at, :updated_at).merge(tags: transaction.tags.map(&:name))
  end

  def encode_cursor(record)
    Base64.urlsafe_encode64({ updated_at: record.updated_at.iso8601(6), id: record.id }.to_json, padding: false)
  end

  def decode_cursor(cursor)
    return if cursor.blank?

    data = JSON.parse(Base64.urlsafe_decode64(cursor))
    { updated_at: Time.iso8601(data.fetch("updated_at")), id: Integer(data.fetch("id")) }
  rescue ArgumentError, JSON::ParserError, KeyError
    raise ArgumentError
  end
end

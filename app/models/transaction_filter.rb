# Filters the activity list from query params. Plain Ruby so it can be built
# from params, rendered in a form and tested without a request.
class TransactionFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :q, :string
  attribute :account_id, :integer
  attribute :category_id, :integer
  attribute :kind, :string
  attribute :from, :date
  attribute :to, :date
  attribute :month, :string

  def initialize(user, params = {})
    @user = user
    super(params.to_h.symbolize_keys.slice(*self.class.attribute_names.map(&:to_sym)))
  end

  def active?
    attributes.except("month").values.any?(&:present?)
  end

  # Without explicit dates the list shows one month at a time ("2024-03").
  def period
    return (from || Date.new(2000))..(to || Date.current) if from || to

    start = Date.strptime(month.to_s, "%Y-%m") rescue Date.current.beginning_of_month
    start.all_month
  end

  def by_month?
    from.nil? && to.nil?
  end

  def transactions
    scope = @user.transactions.includes(:account, :category)
    scope = scope.where(account_id: account_id) if account_id
    scope = scope.where(category_id: category_id) if category_id
    scope = scope.where(kind: kind) if kind.in?(Transaction.kinds.keys)
    scope = scope.where("description ILIKE ?", "%#{Transaction.sanitize_sql_like(q.strip)}%") if q.present?
    within_dates(scope)
  end

  # Transfers have no category, kind or description to match, so only show
  # them when the filter is about accounts or dates.
  def transfers
    return Transfer.none if q.present? || category_id || kind.present?

    scope = @user.transfers.includes(:from_account, :to_account)
    scope = scope.where(from_account_id: account_id).or(scope.where(to_account_id: account_id)) if account_id
    within_dates(scope)
  end

  def totals
    sums = transactions.reorder(nil).group(:kind).sum(:amount_cents)
    income, expense = sums.fetch("income", 0), sums.fetch("expense", 0)
    { income: income, expense: expense, net: income - expense }
  end

  private

  def within_dates(scope)
    scope.where(occurred_on: period)
  end
end

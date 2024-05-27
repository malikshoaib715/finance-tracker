# Everything a user has put into the app, as one JSON document they can keep
# or take elsewhere. Amounts are given in minor units, as stored.
class User::DataExport
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      exported_at: Time.current.iso8601,
      user: @user.slice(:name, :email, :currency, :time_zone),
      accounts: @user.accounts.order(:id).map { |a| a.slice(:id, :name, :kind, :currency, :opening_balance_cents, :archived_at) },
      categories: @user.categories.order(:id).map { |c| c.slice(:id, :name, :kind, :color) },
      tags: @user.tags.order(:id).pluck(:name),
      transactions: @user.transactions.includes(:tags).order(:occurred_on, :id).map do |t|
        t.slice(:id, :account_id, :category_id, :kind, :amount_cents, :occurred_on, :description, :notes)
          .merge(tags: t.tags.map(&:name))
      end,
      transfers: @user.transfers.order(:occurred_on, :id).map { |t| t.slice(:from_account_id, :to_account_id, :amount_cents, :occurred_on, :description) },
      budgets: @user.budgets.order(:month).map { |b| b.slice(:category_id, :month, :amount_cents) },
      recurring_transactions: @user.recurring_transactions.order(:id).map do |r|
        r.slice(:account_id, :category_id, :kind, :amount_cents, :description, :frequency, :next_on, :ends_on, :active)
      end,
      goals: @user.goals.order(:id).map { |g| g.slice(:name, :target_cents, :saved_cents, :target_on, :account_id) },
      rules: @user.rules.order(:id).map { |r| r.slice(:pattern, :category_id) }
    }
  end
end

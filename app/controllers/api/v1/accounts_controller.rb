class Api::V1::AccountsController < Api::V1::BaseController
  def index
    accounts = current_user.accounts.ordered.with_balances
    render json: { accounts: accounts.map { |account| serialize(account) } }
  end

  private

  def serialize(account)
    account.slice(:id, :name, :kind, :currency, :position, :opening_balance_cents, :archived_at, :updated_at)
      .merge(balance_cents: account.balance_cents)
  end
end

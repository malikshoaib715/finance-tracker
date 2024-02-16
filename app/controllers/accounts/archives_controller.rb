class Accounts::ArchivesController < ApplicationController
  before_action :set_account

  def create
    @account.archive!
    redirect_to accounts_path, notice: "#{@account.name} was archived."
  end

  def destroy
    @account.unarchive!
    redirect_to accounts_path, notice: "#{@account.name} is active again."
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:account_id])
  end
end

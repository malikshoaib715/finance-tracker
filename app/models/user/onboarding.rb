# The first few things a new user should do, and whether they've done them.
class User::Onboarding
  Step = Data.define(:title, :done, :path_helper)

  def initialize(user)
    @user = user
  end

  def steps
    @steps ||= [
      Step.new("Add an account", @user.accounts.exists?, :new_account_path),
      Step.new("Record a transaction", @user.transactions.exists?, :new_transaction_path),
      Step.new("Set a monthly budget", @user.budgets.exists?, :new_budget_path),
      Step.new("Import a bank statement", @user.imports.completed.exists?, :new_import_path)
    ]
  end

  def complete?
    steps.all?(&:done)
  end

  def done_count
    steps.count(&:done)
  end
end

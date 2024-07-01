# Fills an account with a believable year of finances for demos and screenshots:
# salary, rent, bills, groceries, eating out, transfers, budgets and goals.
# Deterministic for a given seed so screenshots stay the same.
class DemoData
  EXPENSES = [
    # description,            category,            min,    max,    times/month
    [ "Imtiaz Supermarket",     "Groceries",         3_500,  9_000,  4 ],
    [ "Al-Fatah",               "Groceries",         1_500,  4_000,  2 ],
    [ "Careem",                 "Transport",           350,  1_200,  6 ],
    [ "PSO fuel",               "Transport",         4_000,  7_500,  2 ],
    [ "Foodpanda",              "Eating out",          900,  2_800,  3 ],
    [ "Daewoo café",            "Eating out",          600,  1_500,  1 ],
    [ "Daraz order",            "Shopping",          1_200,  8_000,  1 ],
    [ "Pharmacy",               "Health",              500,  3_000,  1 ]
  ].freeze

  BILLS = [
    [ "Flat rent",            "Rent",              65_000, 1 ],
    [ "K-Electric bill",      "Utilities",         12_000, 5 ],
    [ "SSGC gas bill",        "Utilities",          2_500, 6 ],
    [ "PTCL Flash Fiber",     "Mobile & internet",  4_200, 8 ],
    [ "Jazz postpaid",        "Mobile & internet",  1_800, 10 ]
  ].freeze

  def initialize(user, months: 12, seed: 2024, today: Date.current)
    @user = user
    @months = months
    @random = Random.new(seed)
    @today = today
  end

  def generate
    ActiveRecord::Base.transaction do
      Category.create_defaults_for(@user)
      create_accounts
      create_history
      create_budgets
      create_extras
    end
  end

  private

  def category(name) = @user.categories.find_by!(name: name)

  def create_accounts
    @bank = @user.accounts.find_or_create_by!(name: "Meezan Current") { |a| a.assign_attributes(kind: "bank", currency: "PKR", opening_balance_cents: 18_500_000) }
    @cash = @user.accounts.find_or_create_by!(name: "Wallet cash") { |a| a.assign_attributes(kind: "cash", currency: "PKR", opening_balance_cents: 1_200_000) }
    @card = @user.accounts.find_or_create_by!(name: "HBL Credit Card") { |a| a.assign_attributes(kind: "credit_card", currency: "PKR") }
    @savings = @user.accounts.find_or_create_by!(name: "UBL Savings") { |a| a.assign_attributes(kind: "savings", currency: "PKR", opening_balance_cents: 45_000_000) }
  end

  def create_history
    first = (@today << (@months - 1)).beginning_of_month
    (0...@months).each do |offset|
      month = first >> offset
      record(@bank, "income", "Salary", "Salary #{month.strftime('%B')}", 285_000, month + 0) if month + 0 <= @today
      BILLS.each { |desc, cat, amount, day| record(@bank, "expense", cat, desc, vary(amount, 0.08), month + (day - 1)) }
      EXPENSES.each do |desc, cat, min, max, times|
        times.times do
          account = [ @card, @cash, @bank ][@random.rand(3)]
          record(account, "expense", cat, desc, @random.rand(min..max), month + @random.rand(month.end_of_month.day))
        end
      end
      transfer(@bank, @cash, 25_000, month + 2, "ATM withdrawal")
      transfer(@bank, @savings, 40_000, month + 1, "Monthly saving")
      transfer(@bank, @card, 30_000, month + 20, "Card payment")
      record(@savings, "income", "Profit & returns", "Savings profit", vary(3_200, 0.1), month.end_of_month)
    end
  end

  def create_budgets
    month = @today.beginning_of_month
    { "Groceries" => 45_000, "Eating out" => 10_000, "Transport" => 20_000, "Shopping" => 8_000 }.each do |name, limit|
      [ month.prev_month, month ].each do |m|
        @user.budgets.find_or_create_by!(category: category(name), month: m) { |b| b.amount_cents = limit * 100 }
      end
    end
  end

  def create_extras
    @user.rules.find_or_create_by!(pattern: "Imtiaz") { |r| r.category = category("Groceries") }
    @user.rules.find_or_create_by!(pattern: "Careem") { |r| r.category = category("Transport") }
    @user.goals.find_or_create_by!(name: "Umrah 2025") { |g| g.assign_attributes(target_cents: 60_000_000, saved_cents: 21_500_000, target_on: @today.next_year.end_of_year) }
    @user.goals.find_or_create_by!(name: "Emergency fund") { |g| g.assign_attributes(target_cents: 90_000_000, account: @savings) }
    @user.recurring_transactions.find_or_create_by!(description: "Flat rent") do |r|
      r.assign_attributes(account: @bank, category: category("Rent"), kind: "expense", amount_cents: 6_500_000, frequency: "monthly", next_on: @today.next_month.beginning_of_month)
    end
  end

  def record(account, kind, category_name, description, rupees, date)
    return if date > @today

    @user.transactions.create!(account:, kind:, category: category(category_name), description:,
                               amount_cents: rupees * 100, occurred_on: date)
  end

  def transfer(from, to, rupees, date, description)
    return if date > @today

    @user.transfers.create!(from_account: from, to_account: to, amount_cents: rupees * 100, occurred_on: date, description:)
  end

  def vary(amount, spread)
    (amount * (1 + @random.rand(-spread..spread))).round
  end
end

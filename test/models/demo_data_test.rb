require "test_helper"

class DemoDataTest < ActiveSupport::TestCase
  test "builds a year of believable data for a fresh user" do
    user = User.create!(name: "Demo Person", email: "demo-person@example.com", password: "password123")

    DemoData.new(user, months: 12, today: Date.new(2024, 7, 1)).generate

    assert_equal 4, user.accounts.count
    assert_operator user.transactions.count, :>, 250
    assert_equal 12, user.transactions.where(description: "Flat rent").count
    assert user.transactions.where("occurred_on > ?", Date.new(2024, 7, 1)).none?
    assert user.budgets.any? && user.goals.any? && user.rules.any?
  end

  test "is deterministic for a seed" do
    a = User.create!(name: "A Person", email: "a@example.com", password: "password123")
    b = User.create!(name: "B Person", email: "b@example.com", password: "password123")
    [ a, b ].each { |user| DemoData.new(user, months: 2, today: Date.new(2024, 7, 1)).generate }

    assert_equal a.transactions.sum(:amount_cents), b.transactions.sum(:amount_cents)
  end
end

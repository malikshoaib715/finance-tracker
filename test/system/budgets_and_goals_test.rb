require "application_system_test_case"

class BudgetsAndGoalsTest < ApplicationSystemTestCase
  setup { login_as users(:ayesha) }

  test "setting a budget and seeing it on the dashboard" do
    users(:ayesha).categories.create!(name: "Health", kind: "expense", color: "red")
    visit budgets_path
    click_on "New budget"
    select "Health", from: "Category"
    fill_in "Monthly limit", with: "8000"
    click_on "Save budget"

    assert_text "Budget for Health saved."
    assert_text "Rs 8,000.00 left"

    visit dashboard_path
    assert_selector "h2", text: "Budgets"
    assert_text "Rent"
  end

  test "creating a goal shows the monthly amount needed" do
    visit goals_path
    click_on "New goal"
    fill_in "What are you saving for?", with: "New laptop"
    fill_in "Target amount", with: "300000"
    fill_in "By (optional)", with: (Date.current >> 6).end_of_month
    fill_in "Saved so far (if not linked)", with: "60000"
    click_on "Save goal"

    assert_text "Goal “New laptop” added."
    assert_text "Save Rs 40,000.00/month to make it"
  end
end

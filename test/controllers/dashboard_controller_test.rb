require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to sign in" do
    get dashboard_url
    assert_redirected_to new_user_session_url
  end

  test "shows the dashboard to signed in users" do
    sign_in users(:ayesha)
    get dashboard_url
    assert_response :success
    assert_select "h1", "Dashboard"
  end

  test "root goes to the dashboard once signed in" do
    sign_in users(:ayesha)
    get root_url
    assert_select "h1", "Dashboard"
  end

  test "summarises this month" do
    sign_in users(:ayesha)
    get dashboard_url
    assert_select ".card", text: /Income this month\s+Rs 250,000.00/
    assert_select ".card", text: /Spent this month\s+-Rs 69,350.00/
    assert_select ".card", text: /Net\s+Rs 180,650.00/
  end

  test "shows the month's budgets, most used first" do
    sign_in users(:ayesha)
    get dashboard_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(budgets(:ayesha_rent))} + ##{ActionView::RecordIdentifier.dom_id(budgets(:ayesha_groceries))}"
  end

  test "charts this month's spending by category" do
    sign_in users(:ayesha)
    get dashboard_url
    assert_select "h2", "Where the money went"
    assert_match "Groceries", response.body
    assert_match "Chartkick", response.body
  end

  test "lists recurring items due in the next two weeks" do
    sign_in users(:ayesha)
    get dashboard_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(recurring_transactions(:rent), :upcoming)}", text: /Today/
    assert_select "##{ActionView::RecordIdentifier.dom_id(recurring_transactions(:netflix), :upcoming)}", count: 0
  end

  test "shows the getting started checklist until it's complete" do
    sign_in users(:ayesha)
    get dashboard_url
    assert_select "h2", "Getting started"
    assert_select "a", "Import a bank statement"
  end
end

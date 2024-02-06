require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "signing up lands on the dashboard" do
    visit root_path
    click_on "Get started"

    fill_in "Name", with: "Hamza Tariq"
    fill_in "Email", with: "hamza@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_on "Create account"

    assert_text "Welcome! You have signed up successfully."
    assert_selector "h1", text: "Dashboard"
    assert_text "Hamza"
  end

  test "signing in and out" do
    visit new_user_session_path
    fill_in "Email", with: users(:ayesha).email
    fill_in "Password", with: "password123"
    click_button "Sign in"

    assert_selector "h1", text: "Dashboard"

    click_on "Ayesha"
    click_on "Sign out"

    assert_text "Signed out successfully."
    assert_link "Sign in"
  end

  test "wrong password shows an error" do
    visit new_user_session_path
    fill_in "Email", with: users(:ayesha).email
    fill_in "Password", with: "not-it"
    click_button "Sign in"

    assert_text "Invalid Email or password."
  end
end

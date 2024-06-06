require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  setup do
    login_as users(:ayesha)
  end

  test "category list follows the expense/income toggle" do
    visit new_transaction_path

    assert_selector "optgroup[label=Expenses]:not([disabled])"
    assert_selector "optgroup[label=Incomes][disabled]", visible: :all

    find("label", text: "Income").click

    assert_selector "optgroup[label=Incomes]:not([disabled])"
    assert_selector "optgroup[label=Expenses][disabled]", visible: :all
  end

  test "recording an expense" do
    visit new_transaction_path

    fill_in "Amount", with: "1250"
    fill_in "Description", with: "Careem rides"
    select "Meezan Current", from: "Account"
    select "Groceries", from: "Category"
    click_on "Create Transaction"

    assert_text "Transaction added."
    assert_text "Careem rides"
    assert_text "-Rs 1,250.00"
  end

  test "bulk-setting a category" do
    visit transactions_path
    assert_no_selector "#bulk-actions"

    check "Select Flat rent"
    check "Select Imtiaz weekly shop"
    assert_text "2 selected"

    within("#bulk-actions") do
      select "Groceries", from: "category_id"
      click_on "Set category"
    end

    assert_text "Updated 2 transactions."
    assert_equal categories(:ayesha_groceries), transactions(:rent).reload.category
  end
end

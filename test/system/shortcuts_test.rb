require "application_system_test_case"

class ShortcutsTest < ApplicationSystemTestCase
  setup { login_as users(:ayesha) }

  test "n opens a new transaction and / focuses search" do
    visit transactions_path
    find("body").send_keys("/")
    assert_equal "filter_q", page.evaluate_script("document.activeElement.id")

    find("body").click
    page.execute_script("document.activeElement.blur()")
    find("body").send_keys("n")
    assert_selector "h1", text: "New transaction"
  end

  test "typing n inside a field doesn't navigate" do
    visit transactions_path
    fill_in "filter_q", with: "n"
    assert_selector "h1", text: "Transactions"
  end
end

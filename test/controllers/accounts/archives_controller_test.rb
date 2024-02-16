require "test_helper"

class Accounts::ArchivesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "archives and restores an account" do
    account = accounts(:ayesha_cash)

    post account_archive_url(account)
    assert_redirected_to accounts_url
    assert account.reload.archived?

    delete account_archive_url(account)
    assert_not account.reload.archived?
  end

  test "archived accounts are listed separately" do
    accounts(:ayesha_cash).archive!
    get accounts_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(accounts(:ayesha_cash))}", count: 0
    assert_select "##{ActionView::RecordIdentifier.dom_id(accounts(:ayesha_cash), :archived)}"
  end
end

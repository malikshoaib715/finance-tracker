require "test_helper"

class SummaryMailerTest < ActionMailer::TestCase
  test "summarises a month for the user" do
    mail = SummaryMailer.monthly(users(:ayesha), month: Date.current)

    assert_equal [ "ayesha@example.com" ], mail.to
    assert_equal "Your #{Date.current.strftime('%B %Y')} in numbers", mail.subject
    body = mail.text_part.body.to_s
    assert_match "Income: Rs 250,000.00", body
    assert_match "Spent:  Rs 69,350.00", body
    assert_match "Rent: Rs 65,000.00", body
    assert_match "over budget", mail.html_part.body.to_s
  end
end

require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "lists subscriptions with a monthly total, alerts and the forwarding address" do
    subscriptions(:ayesha_icloud).events.create!(kind: "failed", occurred_on: Date.current, card_last4: "9729", source: "email")
    subscriptions(:ayesha_icloud).update!(status: "failing")

    get subscriptions_url

    assert_response :success
    assert_select "##{ActionView::RecordIdentifier.dom_id(subscriptions(:ayesha_icloud))}", text: /payment failing/
    assert_select "li", text: /iCloud\+: payment failing on card ••9729/
    assert_select "li", text: /DramaBox bills weekly/
    assert_select "code", text: /\Areceipts-\w+@/
  end
end

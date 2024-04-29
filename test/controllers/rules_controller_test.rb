require "test_helper"

class RulesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "lists rules" do
    get rules_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(rules(:imtiaz))}", text: /imtiaz/
  end

  test "adds, edits and removes a rule" do
    assert_difference "Rule.count" do
      post rules_url, params: { rule: { pattern: "K-ELECTRIC", category_id: categories(:ayesha_rent).id } }
    end
    rule = Rule.last

    patch rule_url(rule), params: { rule: { pattern: "K-Electric bill" } }
    assert_equal "K-Electric bill", rule.reload.pattern

    assert_difference "Rule.count", -1 do
      delete rule_url(rule)
    end
  end

  test "shows errors for a bad rule" do
    post rules_url, params: { rule: { pattern: "x", category_id: categories(:ayesha_rent).id } }
    assert_response :unprocessable_entity
  end

  test "applies rules to existing uncategorised transactions" do
    transactions(:groceries).update_columns(category_id: nil)

    post rule_application_url
    assert_redirected_to rules_url
    assert_equal "Categorised 1 transaction.", flash[:notice]
    assert_equal categories(:ayesha_groceries), transactions(:groceries).reload.category
  end
end

require "test_helper"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "lists goals with progress" do
    get goals_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(goals(:umrah))}", text: /Save Rs 45,000.00\/month/
    assert_select "##{ActionView::RecordIdentifier.dom_id(goals(:emergency_fund))}", text: /Reached/
  end

  test "creates, updates and deletes a goal" do
    assert_difference "Goal.count" do
      post goals_url, params: { goal: { name: "Laptop", target: "350,000", saved: "50,000" } }
    end
    goal = Goal.last
    assert_equal [ 35_000_000, 5_000_000 ], [ goal.target_cents, goal.saved_cents ]

    patch goal_url(goal), params: { goal: { saved: "120000" } }
    assert_equal 12_000_000, goal.reload.saved_cents

    assert_difference "Goal.count", -1 do
      delete goal_url(goal)
    end
  end
end

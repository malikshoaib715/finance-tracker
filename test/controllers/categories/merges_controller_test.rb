require "test_helper"

class Categories::MergesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "moves transactions and rules, then deletes the old category" do
    eating_out = users(:ayesha).categories.create!(name: "Takeaway", kind: "expense", color: "orange")
    transactions(:groceries).update!(category: eating_out)
    rules(:imtiaz).update!(category: eating_out)

    assert_difference "Category.count", -1 do
      post category_merge_url(eating_out), params: { target_id: categories(:ayesha_groceries).id }
    end
    assert_redirected_to category_url(categories(:ayesha_groceries))
    assert_equal categories(:ayesha_groceries), transactions(:groceries).reload.category
    assert_equal categories(:ayesha_groceries), rules(:imtiaz).reload.category
  end

  test "keeps the target's budget when both have one that month" do
    assert_difference "Budget.count", -1 do
      post category_merge_url(categories(:ayesha_rent)), params: { target_id: categories(:ayesha_groceries).id }
    end
    assert_equal 500_000, budgets(:ayesha_groceries).reload.amount_cents
  end

  test "won't merge across kinds" do
    post category_merge_url(categories(:ayesha_rent)), params: { target_id: categories(:ayesha_salary).id }
    assert_response :not_found
  end
end

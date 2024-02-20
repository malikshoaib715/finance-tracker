require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "lists expense and income categories" do
    get categories_url
    assert_response :success
    assert_select "h2", "Expenses"
    assert_select "##{ActionView::RecordIdentifier.dom_id(categories(:ayesha_salary))}"
    assert_select "##{ActionView::RecordIdentifier.dom_id(categories(:bilal_groceries))}", count: 0
  end

  test "new form preselects the requested kind" do
    get new_category_url(kind: "income")
    assert_select "select#category_kind option[selected][value=income]"
  end

  test "creates, updates and deletes a category" do
    assert_difference "Category.count" do
      post categories_url, params: { category: { name: "Gifts", kind: "expense", color: "pink" } }
    end
    category = Category.last

    patch category_url(category), params: { category: { name: "Gifts & donations" } }
    assert_equal "Gifts & donations", category.reload.name

    assert_difference "Category.count", -1 do
      delete category_url(category)
    end
  end

  test "cannot touch another user's category" do
    delete category_url(categories(:bilal_groceries))
    assert_response :not_found
  end
end

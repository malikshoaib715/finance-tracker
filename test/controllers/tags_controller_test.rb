require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:ayesha) }

  test "lists tags with how often they're used" do
    get tags_url
    assert_select "##{ActionView::RecordIdentifier.dom_id(tags(:ayesha_family))}", text: /1 transaction/
  end

  test "renames a tag" do
    patch tag_url(tags(:ayesha_ramadan)), params: { tag: { name: "Eid" } }
    assert_equal "eid", tags(:ayesha_ramadan).reload.name
  end

  test "renaming onto an existing tag merges them" do
    transactions(:rent).update!(tag_list: "ramadan")

    assert_difference "Tag.count", -1 do
      patch tag_url(tags(:ayesha_ramadan)), params: { tag: { name: "family" } }
    end
    assert_equal "Merged into #family.", flash[:notice]
    assert_equal %w[family], transactions(:rent).reload.tags.map(&:name)
  end

  test "removes a tag" do
    assert_difference "Tagging.count", -1 do
      delete tag_url(tags(:ayesha_family))
    end
  end
end

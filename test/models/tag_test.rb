require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "names are normalised and unique per user" do
    tag = users(:ayesha).tags.build(name: "  #Family ")
    assert_equal "family", tag.name
    assert_not tag.valid?
    assert users(:bilal).tags.build(name: "family").valid?
  end

  test "tag_list assigns existing tags and creates new ones" do
    transaction = transactions(:rent)
    assert_difference "Tag.count", 1 do
      transaction.update!(tag_list: "Family, #housing, family")
    end
    assert_equal "family, housing", transaction.reload.tags.order(:name).map(&:name).join(", ")
  end

  test "deleting a transaction removes its taggings but keeps the tag" do
    assert_difference "Tagging.count", -1 do
      transactions(:groceries).destroy
    end
    assert tags(:ayesha_family).reload.persisted?
  end
end

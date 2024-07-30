require "test_helper"

class ReportsCacheTest < ActionDispatch::IntegrationTest
  setup do
    @original_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    sign_in users(:ayesha)
  end

  teardown { Rails.cache = @original_store }

  test "cached reports still tag chart scripts with this request's nonce" do
    2.times do
      get reports_url
      nonce = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
      assert_select "script[nonce=?]", nonce, minimum: 3
    end
  end
end

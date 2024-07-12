require "test_helper"

class Reports::YearsControllerTest < ActionDispatch::IntegrationTest
  test "shows a year in review" do
    sign_in users(:ayesha)
    get reports_year_url
    assert_select "h1", "#{Date.current.year} in review"
    get reports_year_url(year: 2023)
    assert_select "h1", "2023 in review"
  end
end

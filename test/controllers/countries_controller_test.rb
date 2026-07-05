require "test_helper"

class CountriesControllerTest < ActionDispatch::IntegrationTest
  test "departments returns a JSON list for the country" do
    get departments_country_url(countries(:honduras))
    assert_response :success
    names = JSON.parse(@response.body).map { |d| d["name"] }
    assert_includes names, departments(:two).name
  end
end

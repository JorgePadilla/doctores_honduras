require "test_helper"

class CountryTest < ActiveSupport::TestCase
  test "has departments and cities through them" do
    hn = countries(:honduras)
    assert_includes hn.departments, departments(:two)
    assert_includes hn.cities, cities(:two)
  end

  test "name is required and unique" do
    dup = Country.new(name: "Honduras")
    assert_not dup.valid?
  end
end

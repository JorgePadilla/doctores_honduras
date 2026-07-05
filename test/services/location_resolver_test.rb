require "test_helper"

class LocationResolverTest < ActiveSupport::TestCase
  test "matches country, region and city by accent-insensitive name" do
    loc = LocationResolver.from_geo(country: "Honduras", region: "Cortes", city: "San Pedro Sula")
    assert_equal countries(:honduras), loc[:country]
    assert_equal departments(:two), loc[:department]
    assert_equal cities(:two), loc[:city]
  end

  test "city is resolved within the matched department" do
    # "San Pedro Sula" belongs to Cortés, so a Francisco Morazán region yields no city.
    loc = LocationResolver.from_geo(country: "Honduras", region: "Francisco Morazán", city: "San Pedro Sula")
    assert_equal departments(:one), loc[:department]
    assert_nil loc[:city]
  end

  test "returns empty for blank or unknown geo" do
    assert_equal({}, LocationResolver.from_geo({}))
    assert_nil LocationResolver.from_geo(country: "Narnia")[:country]
  end
end

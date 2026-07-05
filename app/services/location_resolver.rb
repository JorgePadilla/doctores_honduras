# Matches an IpGeolocator geo hash ({ country:, region:, city:, ... }) to our
# Country/Department/City records by accent-insensitive name. The city is
# resolved within the matched department (disambiguates duplicate city names).
# Returns only the keys that resolve.
class LocationResolver
  def self.from_geo(geo)
    return {} if geo.blank?

    country = match(Country.all, geo[:country])
    departments = country ? country.departments : Department.all
    department = match(departments, geo[:region])
    cities = department ? department.cities : City.all
    city = match(cities, geo[:city])

    { country: country, department: department, city: city }.compact
  end

  def self.match(scope, name)
    return nil if name.blank?

    key = normalize(name)
    scope.to_a.find { |record| normalize(record.name) == key }
  end

  def self.normalize(str)
    I18n.transliterate(str.to_s).downcase.strip
  end
end

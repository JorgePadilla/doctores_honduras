# The app currently serves Honduras. The Country level exists so the location
# filter (País → Departamento → Ciudad) can support more countries later.
# Idempotent; also backfills any department left without a country.
puts "Seeding countries..."

honduras = Country.find_or_create_by!(name: "Honduras") { |c| c.iso_code = "HN" }
Department.where(country_id: nil).update_all(country_id: honduras.id)

puts "Countries ready (#{Country.count})"

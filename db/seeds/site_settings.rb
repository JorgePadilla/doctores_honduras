# Ensure a row exists for each toggleable public section (idempotent).
# Sections default to visible; the admin panel flips these flags.
puts "Seeding site settings..."

SiteSetting::SECTIONS.each_key do |key|
  SiteSetting.find_or_create_by!(key: key) { |setting| setting.enabled = true }
end

puts "Site settings ready (#{SiteSetting.count} sections)"

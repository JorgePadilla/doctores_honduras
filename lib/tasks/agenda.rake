namespace :agenda do
  desc "Grant a user a doctor profile + Elite subscription (agenda access). " \
       "Usage: bin/rails 'agenda:grant_elite[email@example.com]'"
  task :grant_elite, [ :email ] => :environment do |_t, args|
    email = args[:email].to_s.strip
    abort "Usage: bin/rails 'agenda:grant_elite[email@example.com]'" if email.blank?

    user = User.find_by("LOWER(email) = ?", email.downcase)
    abort "No existe un usuario con el correo #{email}" unless user
    puts "Usuario: #{user.email} (id=#{user.id}, profile_type=#{user.profile_type.inspect})"

    # 1) Ensure the account is a doctor with a profile.
    user.update!(profile_type: "doctor") unless user.profile_type == "doctor"

    profile = user.doctor_profile
    unless profile
      dept = Department.first
      city = City.first
      abort "No hay Department/City sembrados; no puedo crear el perfil de doctor." unless dept && city
      profile = user.create_doctor_profile!(
        name: user.email.split("@").first.tr(".", " ").titleize,
        department: dept,
        city: city
      )
      puts "Perfil de doctor creado (##{profile.id})."
    end

    # 2) Assign the Elite plan.
    plan = SubscriptionPlan.find_by(profile_type: "doctor", tier: "elite")
    abort "No se encontró el plan doctor/elite (siembra los planes primero)." unless plan

    sub = user.subscription || user.build_subscription
    sub.subscription_plan = plan
    sub.plan_name = plan.name if sub.respond_to?(:plan_name)
    sub.status = "active"
    sub.current_period_start = Time.current
    sub.current_period_end = 100.years.from_now
    sub.save!

    puts "✅ Elite otorgado a #{user.email} (plan=#{plan.name}, tier=#{plan.tier}, status=#{sub.status})."
    puts "Ya puede entrar a /agenda."
  end
end

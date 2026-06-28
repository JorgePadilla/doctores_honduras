namespace :users do
  desc "Make a user an admin. Usage: bin/rails 'users:make_admin[email@example.com]'"
  task :make_admin, [ :email ] => :environment do |_t, args|
    email = args[:email].to_s.strip
    abort "Usage: bin/rails 'users:make_admin[email@example.com]'" if email.blank?

    user = User.find_by("LOWER(email) = ?", email.downcase)
    abort "No existe un usuario con el correo #{email}" unless user

    user.update!(admin: true)
    puts "✅ #{user.email} ahora es administrador (admin=#{user.admin})."
  end
end

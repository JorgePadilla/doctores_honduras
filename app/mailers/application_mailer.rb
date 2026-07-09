class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Doctores Honduras <no-reply@doctoreshonduras.com>")
  layout "mailer"
end

class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Restablece tu contraseña - Doctores Honduras", to: user.email
  end
end

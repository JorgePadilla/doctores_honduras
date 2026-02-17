class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :redirect_if_authenticated, only: [ :new ]

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Correo electrónico o contraseña incorrectos."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end

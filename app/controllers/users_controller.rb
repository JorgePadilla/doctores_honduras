class UsersController < ApplicationController
  skip_before_action :require_authentication, only: [ :new, :create ]
  before_action :redirect_if_authenticated, only: [ :new ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session = @user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: session.id, httponly: true }

      # Create notification preferences
      @user.create_notification_preference if @user.notification_preference.nil?

      # Redirect to onboarding flow
      flash[:success] = "¡Bienvenido! Por favor complete la configuración de su cuenta."
      redirect_to onboarding_profile_type_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

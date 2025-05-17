class SettingsController < ApplicationController
  before_action :require_authentication
  
  def index
    @user = Current.user
    @subscription = @user.subscription
  end
  
  def account
    @user = Current.user
  end
  
  def subscription
    @user = Current.user
    @subscription = @user.subscription
    @plans = SubscriptionPlan.all
  end
  
  def notifications
    @user = Current.user
    @notification_preferences = @user.notification_preferences || @user.build_notification_preferences
  end
  
  def security
    @user = Current.user
    @active_sessions = @user.sessions.order(created_at: :desc)
  end
  
  def language
    @user = Current.user
  end
  
  def update_language
    @user = Current.user
    if @user.update(language_params)
      redirect_to settings_language_path, notice: "Idioma actualizado correctamente."
    else
      render :language, status: :unprocessable_entity
    end
  end
  
  private
  
  def language_params
    params.require(:user).permit(:language)
  end
end

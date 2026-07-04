class NotificationsController < ApplicationController
  def index
    @notifications = Current.user.notifications.recent.includes(:notifiable)
  end

  # Clicking a notification marks it read and sends the user to its target.
  def mark_as_read
    notification = Current.user.notifications.find(params[:id])
    notification.mark_as_read!
    redirect_to(notification.url.presence || notifications_path)
  end

  def mark_all_as_read
    Current.user.notifications.unread.update_all(read: true, read_at: Time.current)
    redirect_back fallback_location: notifications_path, notice: "Todas las notificaciones marcadas como leídas."
  end
end

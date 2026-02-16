class Agenda::NotificationsController < Agenda::BaseController
  def index
    @notifications = Current.user.appointment_notifications.recent.includes(:appointment)
  end

  def mark_as_read
    notification = Current.user.appointment_notifications.find(params[:id])
    notification.mark_as_read!
    redirect_to agenda_notifications_path, notice: "Notificación marcada como leída."
  end

  def mark_all_as_read
    Current.user.appointment_notifications.unread.update_all(read: true, read_at: Time.current)
    redirect_to agenda_notifications_path, notice: "Todas las notificaciones marcadas como leídas."
  end
end

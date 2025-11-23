class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def index
    # Basic counts
    @users_count = User.count
    @doctors_count = DoctorProfile.count
    @active_subscriptions = Subscription.where(status: "active").count

    # Growth metrics
    @new_users_this_week = User.where("created_at >= ?", 1.week.ago).count
    @new_doctors_this_week = DoctorProfile.where("created_at >= ?", 1.week.ago).count

    # Revenue metrics
    @monthly_revenue = Subscription.where(status: "active").joins(:subscription_plan).sum("subscription_plans.price")
    @revenue_growth = calculate_revenue_growth

    # Engagement metrics
    @doctors_with_images = DoctorProfile.joins("INNER JOIN active_storage_attachments ON active_storage_attachments.record_id = doctor_profiles.id AND active_storage_attachments.record_type = 'DoctorProfile' AND active_storage_attachments.name = 'image'").count
    @completion_rate = (@doctors_with_images.to_f / @doctors_count * 100).round(1) rescue 0

    # Alert metrics
    @hidden_profiles = DoctorProfile.where(hidden: true).count
    @incomplete_profiles = DoctorProfile.where("specialty_id IS NULL OR city_id IS NULL OR department_id IS NULL").count
    @pending_approvals = DoctorProfile.where(hidden: false).where("specialty_id IS NULL OR city_id IS NULL OR department_id IS NULL").count

    # Recent activity
    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_doctors = DoctorProfile.order(created_at: :desc).limit(5)

    # Chart data
    @doctor_growth_data = doctor_growth_data
    @revenue_data = revenue_data
  end

  def users
    @users = User.order(created_at: :desc)
  end

  def doctors
    @doctors = DoctorProfile.includes(:user, :city, :department).order(created_at: :desc)
  end

  def subscriptions
    @subscriptions = Subscription.includes(:user, :subscription_plan).order(created_at: :desc)
  end

  def toggle_doctor_visibility
    @doctor = DoctorProfile.find(params[:id])
    @doctor.update(hidden: !@doctor.hidden)

    flash[:success] = @doctor.hidden ? "Perfil ocultado correctamente" : "Perfil hecho visible correctamente"
    redirect_to admin_doctors_path
  end

  def toggle_plan_visibility
    @plan = SubscriptionPlan.find(params[:id])
    @plan.update(visible: !@plan.visible)

    flash[:success] = @plan.visible ? "Plan hecho visible correctamente" : "Plan ocultado correctamente"
    redirect_to admin_subscriptions_path
  end

  def update_plan_price
    @plan = SubscriptionPlan.find(params[:id])
    price_in_cents = (params[:price].to_f * 100).to_i
    if @plan.update(price: price_in_cents)
      flash[:success] = "Precio actualizado correctamente"
    else
      flash[:alert] = "Error al actualizar el precio"
    end
    redirect_to admin_subscriptions_path
  end

  private

  def calculate_revenue_growth
    current_month_revenue = Subscription.where(status: "active", created_at: Time.current.beginning_of_month..Time.current.end_of_month)
                                       .joins(:subscription_plan).sum("subscription_plans.price")
    last_month_revenue = Subscription.where(status: "active", created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
                                    .joins(:subscription_plan).sum("subscription_plans.price")

    if last_month_revenue > 0
      ((current_month_revenue - last_month_revenue) / last_month_revenue.to_f * 100).round(1)
    else
      current_month_revenue > 0 ? 100.0 : 0.0
    end
  end

  def doctor_growth_data
    # Last 7 days doctor growth
    (0..6).map do |i|
      date = i.days.ago.to_date
      {
        date: date.strftime("%a"),
        doctors: DoctorProfile.where("DATE(created_at) = ?", date).count
      }
    end.reverse
  end

  def revenue_data
    # Last 6 months revenue
    (0..5).map do |i|
      month = i.months.ago.beginning_of_month
      {
        month: month.strftime("%b"),
        revenue: Subscription.where(status: "active", created_at: month..month.end_of_month)
                           .joins(:subscription_plan).sum("subscription_plans.price")
      }
    end.reverse
  end

  def require_admin
    unless Current.user&.admin?
      flash[:alert] = "No tienes permisos para acceder a esta sección"
      redirect_to root_path
    end
  end
end

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
    @doctors_with_images = DoctorProfile.where.not(image_url: [ nil, "" ]).count
    @completion_rate = @doctors_count > 0 ? [ (@doctors_with_images.to_f / @doctors_count * 100).round, 100 ].min : 0

    # Alert metrics
    @hidden_profiles = DoctorProfile.where(hidden: true).count
    @incomplete_profiles = DoctorProfile.where("specialty_id IS NULL OR city_id IS NULL OR department_id IS NULL").count
    @pending_approvals = DoctorProfile.where(hidden: false).where("specialty_id IS NULL OR city_id IS NULL OR department_id IS NULL").count

    # Recent activity
    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_doctors = DoctorProfile.includes(:specialty).order(created_at: :desc).limit(5)

    # Chart data
    @doctor_growth_data = doctor_growth_data
    @revenue_data = revenue_data
  end

  def users
    @page = (params[:page] || 1).to_i
    @per_page = 25

    # Totals over the FULL scope (not the paginated page)
    @total_users = User.count
    @admins_count = User.where(admin: true).count
    @users_with_profile = User.where.not(profile_type: [ nil, "" ]).count

    @total_pages = (@total_users.to_f / @per_page).ceil
    @users = User.includes(:sessions).order(created_at: :desc)
                 .offset((@page - 1) * @per_page).limit(@per_page)
  end

  def doctors
    @page = (params[:page] || 1).to_i
    @per_page = 25

    # Totals over the FULL scope (not the paginated page)
    @total_doctors = DoctorProfile.count
    @hidden_doctors = DoctorProfile.where(hidden: true).count
    @active_doctors = @total_doctors - @hidden_doctors
    @doctors_with_image = DoctorProfile.where.not(image_url: [ nil, "" ]).count

    @total_pages = (@total_doctors.to_f / @per_page).ceil
    @doctors = DoctorProfile.includes(:user, :city, :department, :specialty, :subspecialty).order(created_at: :desc)
                            .offset((@page - 1) * @per_page).limit(@per_page)
  end

  def subscriptions
    @page = (params[:page] || 1).to_i
    @per_page = 25

    # Totals / revenue math over the FULL scope (not the paginated page)
    @total_subscriptions = Subscription.count
    @active_subscriptions_count = Subscription.where(status: "active").count
    @canceled_subscriptions = Subscription.where(status: "canceled").count
    @monthly_revenue = Subscription.where(status: "active").joins(:subscription_plan).sum("subscription_plans.price")
    @active_counts_by_plan = Subscription.where(status: "active").group(:subscription_plan_id).count

    @total_pages = (@total_subscriptions.to_f / @per_page).ceil
    @subscriptions = Subscription.includes(:user, :subscription_plan).order(created_at: :desc)
                                 .offset((@page - 1) * @per_page).limit(@per_page)
    @subscription_plans = SubscriptionPlan.all.to_a
  end

  def toggle_doctor_visibility
    @doctor = DoctorProfile.find(params[:id])
    @doctor.update(hidden: !@doctor.hidden)

    flash[:success] = @doctor.hidden ? "Perfil ocultado correctamente" : "Perfil hecho visible correctamente"
    redirect_to admin_doctors_path
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

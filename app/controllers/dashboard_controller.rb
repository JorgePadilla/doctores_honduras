class DashboardController < ApplicationController
  def index
    @user = Current.user
    @profile_type = @user.profile_type
    @subscription = @user.subscription
    @plan = @subscription&.subscription_plan

    case @profile_type
    when "doctor"
      @doctor_profile = @user.doctor_profile
      @completeness = compute_doctor_completeness
    when "hospital", "clinic"
      @establishment = @user.establishments.first
      @completeness = compute_establishment_completeness
    when "vendor"
      @supplier = @user.supplier
      @products_count = @supplier&.products&.count || 0
      @leads_count = @supplier&.lead_contacts&.count || 0
      @completeness = compute_vendor_completeness
    else
      @completeness = 0
    end
  end

  private

  def compute_doctor_completeness
    return 0 unless @doctor_profile
    fields = [ @doctor_profile.name, @doctor_profile.specialty_id, @doctor_profile.department_id,
               @doctor_profile.city_id, @doctor_profile.description, @doctor_profile.image_url,
               @doctor_profile.medical_license ]
    (fields.count(&:present?).to_f / fields.size * 100).round
  end

  def compute_establishment_completeness
    return 0 unless @establishment
    fields = [ @establishment.name, @establishment.address, @establishment.phone,
               @establishment.department_id, @establishment.city_id, @establishment.description,
               @establishment.logo_url ]
    (fields.count(&:present?).to_f / fields.size * 100).round
  end

  def compute_vendor_completeness
    return 0 unless @supplier
    fields = [ @supplier.name, @supplier.phone, @supplier.category,
               @supplier.description, @supplier.email, @supplier.website,
               @supplier.department_id ]
    (fields.count(&:present?).to_f / fields.size * 100).round
  end
end

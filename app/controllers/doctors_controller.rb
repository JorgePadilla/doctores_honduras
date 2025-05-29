class DoctorsController < ApplicationController
  skip_before_action :require_authentication, only: [:index, :show]
  
  def index
    @page = (params[:page] || 1).to_i
    @per_page = 10
    @total_count = DoctorProfile.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    
    # Ensure page is within valid range
    @page = 1 if @page < 1
    @page = @total_pages if @page > @total_pages && @total_pages > 0
    
    # Calculate offset for pagination
    offset = (@page - 1) * @per_page
    
    # Build the base query
    doctors_query = DoctorProfile.includes(:establishments)
    
    # Apply search filter if present
    if params[:q].present?
      query = params[:q].downcase
      
      # Split the query into terms to allow searching for combinations
      # like "Juan La Ceiba" (name + city)
      terms = query.split.map { |term| "%#{term}%" }
      
      # Create conditions for each term to search across name, specialization, city, and state
      conditions = []
      parameters = []
      
      terms.each do |term|
        conditions << "(LOWER(doctor_profiles.name) LIKE ? OR LOWER(doctor_profiles.specialization) LIKE ? OR LOWER(doctor_profiles.city) LIKE ? OR LOWER(doctor_profiles.state) LIKE ?)"
        parameters.push(term, term, term, term)
      end
      
      # Also search in establishments
      establishment_joins = doctors_query.joins("LEFT JOIN doctor_establishments ON doctor_profiles.id = doctor_establishments.doctor_profile_id LEFT JOIN establishments ON doctor_establishments.establishment_id = establishments.id")
      
      # Add establishment name to search
      terms.each do |term|
        conditions << "LOWER(establishments.name) LIKE ?"
        parameters.push(term)
      end
      
      # Combine all conditions with AND to ensure all terms match somewhere
      doctors_query = establishment_joins.where(conditions.join(' AND '), *parameters).distinct
      
      # Recalculate total pages for filtered results
      filtered_count = doctors_query.count
      @total_pages = (filtered_count.to_f / @per_page).ceil
      @page = 1 if @page > @total_pages && @total_pages > 0
      offset = (@page - 1) * @per_page
    end
    
    # Apply pagination
    @doctors = doctors_query.limit(@per_page).offset(offset)
  end
  
  def show
    @doctor = DoctorProfile.find(params[:id])
    @establishments = @doctor.establishments
  end
end

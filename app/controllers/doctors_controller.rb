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
      doctors_query = doctors_query.where(
        "LOWER(name) LIKE ? OR LOWER(specialization) LIKE ?", 
        "%#{query}%", "%#{query}%"
      )
      
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

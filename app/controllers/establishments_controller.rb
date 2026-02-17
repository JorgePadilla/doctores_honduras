class EstablishmentsController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]
  before_action :set_establishment, only: [ :show ]

  def index
    @page = (params[:page] || 1).to_i
    @per_page = 10

    # Build the base query with eager loading
    base_query = Establishment.includes(:specialties, :services, :doctor_profiles)

    # Apply search filters if present
    if params[:q].present?
      search_term = "%#{params[:q]}%"

      # Search by establishment attributes
      establishment_results = base_query.where(
        "name ILIKE ? OR est_type ILIKE ? OR address ILIKE ?",
        search_term, search_term, search_term
      )

      # Search by specialty name
      specialty_results = base_query.joins(:specialties)
                                   .where("specialties.name ILIKE ?", search_term)

      # Search by service name
      service_results = base_query.joins(:services)
                                 .where("services.name ILIKE ?", search_term)

      # Combine all results and remove duplicates
      @establishments = (establishment_results + specialty_results + service_results).uniq
    else
      @establishments = base_query.all
    end

    # Filter by specialty if specified
    if params[:specialty_id].present?
      @establishments = @establishments.joins(:specialties)
                                      .where(specialties: { id: params[:specialty_id] })
    end

    # Filter by service if specified
    if params[:service_id].present?
      @establishments = @establishments.joins(:services)
                                      .where(services: { id: params[:service_id] })
    end

    # Calculate pagination
    @total_count = @establishments.length
    @total_pages = (@total_count.to_f / @per_page).ceil

    # Apply sorting and pagination
    @establishments = @establishments.sort_by(&:name)
                                    .slice((@page - 1) * @per_page, @per_page) || []

    # Load all specialties and services for filter dropdowns
    @all_specialties = Specialty.order(name: :asc)
    @all_services = Service.order(name: :asc)
  end

  def show
    ProfileViewTracker.track(
      viewable: @establishment,
      viewer: Current.user,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    @doctors = @establishment.doctor_profiles.order(name: :asc)
    @specialties = @establishment.specialties.order(name: :asc)
    @services = @establishment.services.order(name: :asc)
  end

  private

  def set_establishment
    @establishment = Establishment.includes(:doctor_profiles, :specialties, :services).find_by(id: params[:id])

    if @establishment.nil?
      flash[:alert] = "No se encontró el establecimiento solicitado"
      redirect_to establishments_path
    end
  end
end

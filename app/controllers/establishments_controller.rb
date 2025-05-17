class EstablishmentsController < ApplicationController
  include Authentication
  before_action :require_authentication
  before_action :set_establishment, only: [:show]

  def index
    @page = (params[:page] || 1).to_i
    @per_page = 10
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @establishments = Establishment.where("name ILIKE ? OR est_type ILIKE ? OR address ILIKE ?", search_term, search_term, search_term)
    else
      @establishments = Establishment.all
    end
    @total_count = @establishments.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    @establishments = @establishments.order(name: :asc).offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @doctors = @establishment.doctor_profiles.order(name: :asc)
    @specialties = @establishment.specialties.order(name: :asc)
    @services = @establishment.services.order(name: :asc)
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:id])
  end
end

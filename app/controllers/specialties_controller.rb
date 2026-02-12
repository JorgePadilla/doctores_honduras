class SpecialtiesController < ApplicationController
  allow_unauthenticated_access only: [:subspecialties, :services]

  def subspecialties
    @specialty = Specialty.find(params[:id])
    @subspecialties = @specialty.subspecialties.order(:name)

    respond_to do |format|
      format.json { render json: @subspecialties }
    end
  end

  def services
    @specialty = Specialty.find(params[:id])
    services = Service.where(specialty_id: [@specialty.id, nil]).order(:name)

    respond_to do |format|
      format.json { render json: services.select(:id, :name) }
    end
  end
end
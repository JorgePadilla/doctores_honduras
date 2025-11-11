class SpecialtiesController < ApplicationController
  allow_unauthenticated_access only: [:subspecialties]

  def subspecialties
    @specialty = Specialty.find(params[:id])
    @subspecialties = @specialty.subspecialties.order(:name)

    respond_to do |format|
      format.json { render json: @subspecialties }
    end
  end
end
class EstablishmentProfilesController < ApplicationController
  before_action :set_establishment

  def edit
    load_form_collections
  end

  def update
    if @establishment.update(establishment_params)
      redirect_to dashboard_path, notice: "Perfil del establecimiento actualizado correctamente."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_establishment
    @establishment = Current.user&.establishments&.first
    redirect_to dashboard_path, alert: "No tienes un establecimiento configurado." if @establishment.nil?
  end

  def load_form_collections
    @departments = Department.order(:name)
    @cities = City.order(:name)
  end

  def establishment_params
    params.require(:establishment).permit(
      :name, :address, :phone, :email, :website, :map_link, :description,
      :department_id, :city_id, :logo_file, :building_image_file
    )
  end
end

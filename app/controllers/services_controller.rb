class ServicesController < ApplicationController
  before_action :require_authentication, only: [:find_or_create]

  def find_or_create
    name = params[:name]&.strip
    if name.blank?
      render json: { error: "Nombre requerido" }, status: :unprocessable_entity
      return
    end

    service = Service.find_or_create_by!(name: name)
    render json: { id: service.id, name: service.name }
  end
end

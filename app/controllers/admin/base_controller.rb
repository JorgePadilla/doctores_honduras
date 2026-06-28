class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    unless Current.user&.admin?
      flash[:alert] = "No tienes permisos para acceder a esta sección"
      redirect_to root_path
    end
  end
end

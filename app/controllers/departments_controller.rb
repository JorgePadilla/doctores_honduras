class DepartmentsController < ApplicationController
  skip_before_action :require_authentication, only: [:cities]

  def cities
    department = Department.find(params[:id])
    cities = department.cities.order(:name)
    render json: cities.map { |c| { id: c.id, name: c.name } }
  end
end

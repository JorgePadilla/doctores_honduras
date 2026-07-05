class CountriesController < ApplicationController
  skip_before_action :require_authentication, only: [ :departments ]

  # JSON list of a country's departments, for the cascading location filter.
  def departments
    country = Country.find(params[:id])
    render json: country.departments.order(:name).map { |d| { id: d.id, name: d.name } }
  end
end

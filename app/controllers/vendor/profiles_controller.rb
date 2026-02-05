class Vendor::ProfilesController < Vendor::BaseController
  def show
    @supplier = current_supplier
  end

  def edit
    @supplier = current_supplier
    @departments = Department.order(:name)
    @cities = City.order(:name)
  end

  def update
    @supplier = current_supplier
    if @supplier.update(supplier_params)
      redirect_to vendor_profile_path, notice: "Perfil actualizado correctamente."
    else
      @departments = Department.order(:name)
      @cities = City.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def supplier_params
    params.require(:supplier).permit(
      :name, :phone, :address, :email, :description,
      :category, :website, :logo_url, :department_id, :city_id
    )
  end
end

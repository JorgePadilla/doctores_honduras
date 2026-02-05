class Vendor::LeadsController < Vendor::BaseController
  before_action :require_paid_plan

  def index
    @leads = current_supplier.lead_contacts.recent
  end

  def show
    @lead = current_supplier.lead_contacts.find(params[:id])
  end

  def update
    @lead = current_supplier.lead_contacts.find(params[:id])
    if @lead.update(lead_params)
      redirect_to vendor_lead_path(@lead), notice: "Estado actualizado."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def lead_params
    params.require(:lead_contact).permit(:status)
  end

  def require_paid_plan
    unless paid_plan?
      redirect_to vendor_profile_path, alert: "Los contactos est\u00E1n disponibles en planes de pago. Actualiza tu plan en Configuraci\u00F3n."
    end
  end
end

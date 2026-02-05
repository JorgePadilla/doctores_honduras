class LeadContactsController < ApplicationController
  skip_before_action :require_authentication

  def new
    @supplier = Supplier.find(params[:supplier_id])
    @lead_contact = @supplier.lead_contacts.build
  end

  def create
    @supplier = Supplier.find(params[:supplier_id])
    @lead_contact = @supplier.lead_contacts.build(lead_contact_params)

    if @lead_contact.save
      redirect_to supplier_path(@supplier), notice: "Mensaje enviado correctamente. El proveedor se pondr\u00E1 en contacto contigo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def lead_contact_params
    params.require(:lead_contact).permit(:name, :email, :phone, :organization, :message)
  end
end

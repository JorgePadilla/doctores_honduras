class ProductsController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]
  before_action :set_supplier

  def index
    @page = (params[:page] || 1).to_i
    @per_page = 10
    
    @products = @supplier.products
    
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @products = @products.where("name ILIKE ? OR category ILIKE ? OR description ILIKE ?", 
                                 search_term, search_term, search_term)
    end
    
    @total_count = @products.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    
    @products = @products.order(name: :asc).offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @product = @supplier.products.find_by(id: params[:id])
    unless @product
      flash[:alert] = "Producto no encontrado."
      redirect_to supplier_products_path(@supplier)
    end
  end

  private

  def set_supplier
    @supplier = Supplier.find_by(id: params[:supplier_id])
    unless @supplier
      flash[:alert] = "Proveedor no encontrado."
      redirect_to suppliers_path
    end
  end
end

class SuppliersController < ApplicationController
  def index
    @page = (params[:page] || 1).to_i
    @per_page = 10
    
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @suppliers = Supplier.where("name ILIKE ? OR description ILIKE ?", search_term, search_term)
    else
      @suppliers = Supplier.all
    end
    
    @total_count = @suppliers.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    
    @suppliers = @suppliers.order(name: :asc).offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @supplier = Supplier.find(params[:id])
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
end

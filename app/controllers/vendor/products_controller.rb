class Vendor::ProductsController < Vendor::BaseController
  before_action :set_product, only: [ :edit, :update, :destroy ]
  before_action :check_product_limit, only: [ :new, :create ]

  def index
    @products = current_supplier.products.order(created_at: :desc)
  end

  def new
    @product = current_supplier.products.build
  end

  def create
    @product = current_supplier.products.build(product_params)
    if @product.save
      redirect_to vendor_products_path, notice: "Producto creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to vendor_products_path, notice: "Producto actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to vendor_products_path, notice: "Producto eliminado."
  end

  private

  def set_product
    @product = current_supplier.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :sku, :description, :price, :category, :image_url, :active, :featured)
  end

  def check_product_limit
    return if paid_plan?
    if current_supplier.products.count >= 5
      redirect_to vendor_products_path, alert: "Has alcanzado el l\u00EDmite de 5 productos en el plan gratuito. Actualiza tu plan para agregar m\u00E1s."
    end
  end

  def product_limit_reached?
    !paid_plan? && current_supplier.products.count >= 5
  end
  helper_method :product_limit_reached?
end

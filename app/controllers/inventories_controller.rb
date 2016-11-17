class InventoriesController < ApplicationController
  
  load_and_authorize_resource :except => [:get_product_amount_at_location]
  skip_authorization_check :only => [:get_product_amount_at_location]

  before_filter :load_permissions # call this after load_and_authorize else it gives a cancan error
  before_action :require_user
  respond_to :html, :json

  before_action :set_menu_expands #for setting which menu items are expanded

  def set_menu_expands
    @menu_expands = ['menuInvDropdown']
  end

  def index
    
    @inventories = Inventory.search(params[:search], params[:location_id], params[:product_category]).order(sort_column + " " + sort_direction).page params[:page]
    respond_with(@inventories)
  end

  def show    
    respond_with(@inventory)
  end

  def new    
    respond_with(@inventory)
  end

  def edit
  end

  def create    
            
    # you need a po to create an inventory
    if (@inventory.purchase_order_id.nil? || @inventory.purchase_order_id < 1) && !@inventory.is_creating_new_purchase_order?                
      @inventory.errors.add(:purchase_order_id, _("You must choose or create a purchase_order"))
      respond_with(@inventory)
      return
    end

    if @inventory.save    
      flash[:success] = _('Inventory was successfully created.') 
      respond_with(@inventory, location: edit_inventory_path(@inventory)) 
    else
      respond_with(@inventory)
    end  
  end

  def update    
    flash[:success] = _('Inventory was successfully updated.') if @inventory.update(inventory_params)    
    respond_with(@inventory, location: edit_inventory_path(@inventory)) 

  end

  def destroy
    res = @inventory.destroy
    flash[:notice] = _('Inventory was successfully deleted.') if res 
    respond_with(@inventory)
  end

  def get_product_amount_at_location
    render json: {amount: Inventory.where(product_type_id: params[:product_type_id], location_id: params[:location_id]).sum(:amount)}  
  end

  private
    # Handled by load_and_authorize_resource
    # def set_inventory
    #   @inventory = Inventory.find(params[:id])
    # end
  
    # Only allow a trusted parameter "white list" through.
    def inventory_params
      params.require(:inventory).permit(:density, :delivery_photo, :delete_delivery_photo, :product_type_id, :amount, :purchased_price, :other_costs, :purchased_date, :location_id, :status, :new_purchase_order_supplier_id, :original_updated_at, :protein_percent, :moisture_percent, :oil_percent, :fiber_percent, :urea_activity_percent, :calcium_percent, :purchase_order_id, :amount_received, :currency_type, :currency_rate)
    end  
end

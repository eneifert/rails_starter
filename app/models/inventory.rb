class Inventory < ActiveRecord::Base  
  include OptimisticLocking
  
  belongs_to :location
  belongs_to :product_type
  belongs_to :purchase_order
    
  has_many :order_product_reservations
  accepts_nested_attributes_for :order_product_reservations, allow_destroy: true
  
  after_initialize :init #used to set default values  

  before_save :on_before_save

  after_save :on_after_save
  after_destroy :on_after_destroy

  validates :amount, presence: {message: _("can't be empty")}
  validate :received_amount_not_empty_if_purchase_order_is_present  
  validate :only_inventory_for_this_purchase_order
  validate :product_type_did_not_change

  attr_accessor :amount_decreased_by_reservation
  attr_accessor :inventory_change_info
  attr_accessor :new_purchase_order_supplier_id


  has_attached_file :delivery_photo,
    styles: {med: "450x450>", thumb: "75x75>"},
    :default_url => "/no_image.jpg",
    :default_style => :med,
    :path => ":rails_root/public/uploaded_images/settings/:id/:style/:filename",
    :url => "/uploaded_images/settings/:id/:style/:filename"
  
  validates_attachment_content_type :delivery_photo, content_type: ["image/jpg", "image/jpeg", "image/gif", "image/png"]    
  validates_attachment_size :delivery_photo, :less_than => 12.megabytes

  before_save :check_delete_delivery_photo
  attr_accessor :delete_delivery_photo
  
  def check_delete_delivery_photo
    if delete_delivery_photo == "true"
      self.delivery_photo = nil       
    end
  end



  def init      
    self.location_id ||= Location::get_default_location.id
    self.purchased_date ||= DateTime.now.change({ min: 0, sec: 0 })    
    self.amount_decreased_by_reservation = false
    self.inventory_change_info ||= {type: InventoryChangeTypes::from_inventory_edit[:id] }
  end

  def self.search(search, location_id, product_category)
    
    where_sql = ""
    where_params = {}

    if !search.blank?

      wild_search = "%#{search.downcase.mb_chars.downcase.to_s}%"

      where_sql = "(lower(product_types.name) like :wild_search or lower(product_types.name_ru) like :wild_search or lower(locations.name) like :wild_search)"
      where_params[:wild_search] = wild_search

      if search.to_i > 0
        where_sql += " or inventories.id = :search"
        where_params[:search] = search.to_i
      end

    end
    
    if !location_id.blank?
            
      where_sql += where_sql.blank? ? "" : " and "
      where_sql += "inventories.location_id = :location_id"
      where_params[:location_id] = location_id

    end

    if !product_category.blank?
      
      where_sql += where_sql.blank? ? "" : " and "
      where_sql += "product_types.type = :product_category"
      where_params[:product_category] = product_category

    end
    
    if !where_sql.blank?
      Inventory.joins(:product_type, :location).where(where_sql, where_params)
    else
      Inventory.includes(:location, :product_type).all
    end
  end

  def amount_free  
    return 0 if self.amount.nil?  
    
  	return self.amount - self.order_product_reservations(true).where(is_done: false).sum(:amount)
  end

  def on_before_save
        
    check_create_purchase_orders

  end  

  def is_creating_new_purchase_order?
    return purchase_order_id == 0 && !new_purchase_order_supplier_id.blank? && new_purchase_order_supplier_id.to_i > 0
  end

  def check_create_purchase_orders

    if is_creating_new_purchase_order?
      
      total = (amount_received || 0) * (purchased_price || 0)
      # create purchase order
      po = PurchaseOrder.create({
        order_date: purchased_date,
        supplier_id: new_purchase_order_supplier_id.to_i,
        payment_duedate: purchased_date,        
        product_type_id: product_type_id,
        negotiated_price_per_kilo: purchased_price,
        estimated_quantity: amount_received,        
        estimated_total_cost: total,        
        amount_received: amount_received,
        price_per_kilo: purchased_price,
        actual_total_cost: total
      })

      self.purchase_order_id = po.id

    end
  end

  def on_after_save
    
    check_effected_orders

    check_effected_purhasing_order

    check_inventory_thresholds

    log_inventory_adjustments
    
  end
  
  def log_inventory_adjustments
    log_user_id = User::current_user.nil? ? nil : User::current_user.id    
        
    # if the location or product type changed    
    if !id_changed? && (location_id_was != location_id || product_type_id_was != product_type_id)      

      # deduct the was_amount from the old location and old product type
      pt_amount_was = product_type.get_amount_at_location(location_id_was) + amount_was
      tmp = InventoryChange.create({
          inventory_change_type: inventory_change_info[:type], 
          amount_was: pt_amount_was, 
          amount_changed_by: 0 - amount_was, 
          product_type_id: product_type_id_was, 
          location_id: location_id_was, 
          user_id: log_user_id,
          order_product_id: inventory_change_info[:order_product_id],
          feed_mill_job_id: inventory_change_info[:feed_mill_job_id],
          inventory_id: self.id,
          moved_inventory_id: inventory_change_info[:moved_inventory_id],
          lost_inventory_id: inventory_change_info[:lost_inventory_id],
          inventory_adjustment_id: inventory_change_info[:inventory_adjustment_id],
          change_date: inventory_change_info[:change_date]
        })
      
    end

    # change_date
    # 1) What if it is a create
      # use purchase_date or DateTime.now
    # 2) What if the purchase date is changed but not the amount
      # then the old InventoryChange record needs changed
    # 3) What if the amount changes

    change_date = inventory_change_info[:change_date] || DateTime.now
    # if it is a new inventory
    if id_changed?      
      change_date = inventory_change_info[:change_date] || self.purchased_date || DateTime.now

    
    elsif purchased_date_was != self.purchased_date 
    
      # update the delivery date
      changes = InventoryChange.where(inventory_id: self.id, change_date: purchased_date_was)
      if changes.length > 0      
        changes.update_all(change_date: purchased_date)

      end
  
      # and log the change in amount!
      change_date = DateTime.now

    elsif !inventory_change_info[:change_date].nil?
      change_date = inventory_change_info[:change_date]

    end

    # log the change in amount    
    pt_amount_was = product_type.get_amount_at_location(location_id)    
    amount_changed_by = 0
      
    if !location_id_was.nil? && location_id != location_id_was
      amount_changed_by = amount

    elsif amount_was.nil? || amount_was < amount
      # if the amount increased
      amount_changed_by = amount - (amount_was || 0)      
    else      
      # if the amount decreased
      amount_changed_by = 0 - (amount_was - amount)      
    end

    pt_amount_was -= amount_changed_by        
    InventoryChange.create({
      inventory_change_type: inventory_change_info[:type], 
      amount_was: pt_amount_was, 
      amount_changed_by: amount_changed_by, 
      product_type_id: product_type_id, 
      location_id: location_id, 
      user_id: log_user_id,
      order_product_id: inventory_change_info[:order_product_id],
      feed_mill_job_id: inventory_change_info[:feed_mill_job_id],
      inventory_id: self.id,
      moved_inventory_id: inventory_change_info[:moved_inventory_id],
      lost_inventory_id: inventory_change_info[:lost_inventory_id],
      inventory_adjustment_id: inventory_change_info[:inventory_adjustment_id],
      change_date: change_date
      })
        
  end

  def on_after_destroy

    inventory_decreased_so_check_orders(self.product_type_id, self.amount)

    check_inventory_thresholds

    pt_amount_was = product_type.get_amount_at_location(location_id) + amount

    InventoryChange.create({
      inventory_change_type: inventory_change_info[:type], 
      amount_was: pt_amount_was, 
      amount_changed_by: 0 - amount, 
      product_type_id: product_type_id, 
      location_id: location_id, 
      user_id: User::current_user.nil? ? nil : User::current_user.id,
      order_product_id: inventory_change_info[:order_product_id],
      feed_mill_job_id: inventory_change_info[:feed_mill_job_id],
      inventory_id: self.id,
      moved_inventory_id: inventory_change_info[:moved_inventory_id],
      lost_inventory_id: inventory_change_info[:lost_inventory_id],
      inventory_adjustment_id: inventory_change_info[:inventory_adjustment_id],
      change_date: DateTime.now
      })
      
  end

  def check_inventory_thresholds    
    InventoryOrder::create_or_remove_replenishment_orders_as_needed(self.product_type_id)    
  end

  def check_effected_purhasing_order
    return if purchase_order.nil?
    
    if (purchased_price_was != purchased_price && !purchased_price.nil?) || (amount_received_was != amount_received && !amount_received.nil?) || (other_costs_was != other_costs && !other_costs.nil?)

      purchase_order.update_columns(amount_received: amount_received, price_per_kilo: purchased_price, other_costs: other_costs, actual_total_cost: (purchased_price || 0) * (amount_received || 0) + (other_costs || 0))
    end
      
  end

  def check_effected_orders    
    
    is_new = self.id_was.nil?

    if is_new || self.amount_was.nil? || self.amount_was < self.amount
      
      inventory_increased_so_check_orders

    elsif self.product_type_id_was != self.product_type_id

      remove_unfinished_reservations
      inventory_increased_so_check_orders
      
    elsif self.amount_was > self.amount              

      inventory_decreased_so_check_orders(self.product_type_id, self.amount_was - self.amount)
    
    end    
  
  end

  def inventory_increased_so_check_orders
      
    sql =  """
      SELECT order_products.id 
      FROM order_products
      LEFT OUTER JOIN rations on order_products.ration_id = rations.id
      LEFT OUTER JOIN ration_products on rations.id = ration_products.ration_id
      WHERE 
        rations.is_active = #{ReportsBase.escape_sql_param(true)} 
        AND (order_products.product_type_id = #{self.product_type_id} or ration_products.product_type_id = #{self.product_type_id})
    """
    ids = ActiveRecord::Base.connection.execute(sql).map { |item| item["id"] }  

    OrderProduct.where("id in (?)", ids).each do |op|
          
      begin
        # check if any orders are waiting on this product_type        
        op.touch
        op.save

      rescue Exceptions::FailedValidations => e        
        # don't throw execption if there still isn't enough inventory
      end
    end

  end

  def remove_unfinished_reservations

    order_product_reservations.where(is_done: false).each do |opr|
      op = OrderProduct.find(opr.order_product_id)
      opr.destroy

      op.update_with_notifications      
    end
  end

  # When the user manually descreses the inventory amount this may affect order reservations
  def inventory_decreased_so_check_orders(prod_type_id, amount_removed)    

    # if it was the reservation itself which decreased the order
    if self.amount_decreased_by_reservation
      self.amount_decreased_by_reservation = false
      return
    end
      
    amount_left = amount_removed
  
    order_product_reservations.where(is_done: false).order('amount desc').each do |opr|
            
      return if amount_left == 0


      if opr.amount > amount_left
        opr.amount -= amount_left

        op = opr.order_product
        opr.sneaky_save
                      
        op.update_with_notifications

        amount_left = 0
      else

        amount_left -= opr.amount
        
        op = opr.order_product
        opr.delete        

        op.update_with_notifications              
        
      end

    end  

  end

  def received_amount_not_empty_if_purchase_order_is_present
    if !purchase_order_id.nil? && (amount_received.nil? || amount_received < 1)
      errors.add(:amount_received, _("Received amount can't be empty when there is a purchase order."))
    end    
  end  

  def only_inventory_for_this_purchase_order
    if !purchase_order_id.nil? && purchase_order_id > 0
      tmp_id = id.nil? ? 0 : id
      if Inventory.where("id <> ? and purchase_order_id = ?", tmp_id, purchase_order_id).count > 0
        errors.add(:purchase_order_id, _("Another order is already using that purchase order"))
      end
    end
  end

  def product_type_did_not_change
    if !id.nil? && product_type_id != product_type_id_was
      errors.add(:product_type_id, _("Can't change product id after creation. Delete the inventory if you want to get rid of it."))
    end
  end

  def self.remove_product(product_type_id, amount, inv_change_info, location_id = Location::get_default_location.id, amount_decreased_by_reservation=false)
    return if amount <= 0
        
    amount_left = amount

    # 1) Try to remove inventory from places that aren't reserved    
    Inventory.where("product_type_id = ? and location_id = ? and amount > 0", product_type_id, location_id).order("id asc").each do |inv|

      break if amount_left == 0

      inv.amount_decreased_by_reservation = amount_decreased_by_reservation
      inv.inventory_change_info = inv_change_info

      tmp_free = inv.amount_free

      if tmp_free > 0
        if tmp_free >= amount_left
          inv.amount -= amount_left
          inv.save
          amount_left = 0
        else
          amount_left -= tmp_free
          inv.amount -= tmp_free
          inv.save          
        end
      end

    end

    return if amount_left == 0

    # 2) Just remove the inventory from anywhere
    Inventory.where(product_type_id: product_type_id, location_id: location_id).order("amount desc").each do |inv|
      break if amount_left == 0
      
      inv.amount_decreased_by_reservation = amount_decreased_by_reservation
      inv.inventory_change_info = inv_change_info

      if inv.amount > amount_left
        inv.amount -= amount_left
        inv.save
        amount_left = 0        
      else
        amount_left -= inv.amount
        inv.amount = 0
        inv.save
      end

    end

    prod = ProductType.find(product_type_id)
    OrderMoreNotification.create({subject: "Had to use reserved inventory for another order. ", body: "Get more #{prod.name}"})
    
    if amount_left != 0
      # what if there isn't enough?
      SystemNotification.create({subject: 'Inventory records are less than actual amounts', body: "The system used #{amount_left} kilos of #{prod.name} more than what should be possible"})
    end    
  end

  def self.add_product(product_type_id, amount, inv_change_info, location_id = Location::get_default_location.id, amount_decreased_by_reservation=false)
    return if amount <= 0
              
    inv = Inventory.new({amount: 0, product_type_id: product_type_id, location_id: location_id})
        
    inv.amount_decreased_by_reservation = amount_decreased_by_reservation
    inv.inventory_change_info = inv_change_info
    inv.purchased_date = inv_change_info[:change_date] || DateTime.now

    most_recent_inv = Inventory.where("product_type_id = ? and purchased_date <= ?", product_type_id, inv.purchased_date).order("purchased_date desc").first
    if most_recent_inv.nil?
      most_recent_inv = Inventory.where("product_type_id = ? and purchased_date > ?", product_type_id, inv.purchased_date).order("purchased_date").first
    end
    
    inv.purchased_price = most_recent_inv.nil? ? nil : most_recent_inv.purchased_price    
    inv.amount += amount
    inv.save
        
  end

  def self.inventory_reserved_for_type(product_type_id, location_id = Location::get_default_location.id)    
    OrderProductReservation.joins(:inventory).where(product_type_id: product_type_id, is_done: false, :inventories => {location_id: location_id}).sum(:amount)   
  end

  def self.total_product_type_at_location(product_type_id, location_id)
    Inventory.where(product_type_id: product_type_id, location_id: location_id).sum(:amount)
  end

  def self.inventory_free_for_type(product_type_id, location_id = Location::get_default_location.id)
    total_free = 0 

    Inventory.where(product_type_id: product_type_id, location_id: location_id).each do |inv|

      total_free += inv.amount_free
    end
    
    return total_free
  end

  belongs_to :purchasing_order_item #legacy support
end

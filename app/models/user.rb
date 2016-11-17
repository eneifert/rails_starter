class User < ActiveRecord::Base
  include OptimisticLocking
  
  has_and_belongs_to_many :roles
  has_many :user_shown_notifications

  belongs_to :location

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  
  def self.current_user=(user)
    Thread.current[:current_user] = user
  end

  def self.current_user
    Thread.current[:current_user]
  end
  
  after_initialize :init #used to set default values  

  def init
    self.location_id ||= Location::get_default_order_location.id
  end

  def self.search(search)
    if !search.blank?

      wild_search = "%#{search.downcase.mb_chars.downcase.to_s}%"      

      where_sql = "lower(name) like :wild_search or lower(email) like :wild_search"
      where_params = {wild_search: wild_search}

      if search.to_i > 0
        where_sql += " or id = :search"
        where_params[:search] = search.to_i
      end

      User.where(where_sql, where_params)
    else
      User.all
    end
  end

  def role?(role)
    [:sales_member].include? role    
  end

  def can_print_batch_sheets?
    roles.each do |r|
      
      return true if r.is_super_admin || r.can_print_batch_sheets
    end

    return false
  end

  def can_upload_rations?
    roles.each do |r|
      
      return true if r.is_super_admin || r.can_upload_rations
    end

    return false
  end

  def is_super_admin?
    roles.each do |r|
      return true if r.is_super_admin
    end

    return false
  end

  # gets all notifications for a user whose id is greater than what is passed in
  def get_notifications(greater_than_id=0)  	
  	  	
  	return Notification.where("type in (?) and id > ?", notification_types, greater_than_id).order("created_at desc")

  end

  def display_name
    name.blank? ? email : name
  end

  def get_unshown_notifications  	
  	shown_ids = UserShownNotification.where(user_id: self.id).pluck(:notification_id)  

  	return Notification.where("type in (?) and id not in (?)", notification_types, shown_ids.blank? ? [0] : shown_ids).order("created_at desc")
  end

  private
  	def notification_types
  		# Roles know what type of notifications to get
  		self.roles(true).map {|r| [r.recieves_order_more_notifications ? NotificationTypes::order_more[:id] : "",  r.recieves_system_notifications ? NotificationTypes::system[:id] : "" ]}.flatten.uniq.reject(&:empty?)
  	end
end

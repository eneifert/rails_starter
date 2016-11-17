class Role < ActiveRecord::Base
  include OptimisticLocking
  
  has_and_belongs_to_many :users
  has_and_belongs_to_many :permissions

  def self.search(search)
    if !search.blank?

      wild_search = "%#{search.downcase.mb_chars.downcase.to_s}%"      

      where_sql = "lower(name) like :wild_search"
      where_params = {wild_search: wild_search}

      if search.to_i > 0
        where_sql += " or id = :search"
        where_params[:search] = search.to_i
      end

      Role.where(where_sql, where_params)
    else
      Role.all
    end
  end

  def self.recieving_manager_select_options()    
    
    rms = [[' ', '']]
    
    Role.where(can_recieve_internal_feed_orders: true).each do |r|
      rms = (rms + r.users.map {|u| ["#{u.id} - " + u.name, u.id]}).uniq
    end 
            
    return rms.sort_by { |e| e[0] }
  end

  def is_super_admin
  	self.permissions.where(name: "All", action: "all", subject_class: "all").count > 0
  end
end
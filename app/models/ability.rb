class Ability
  include CanCan::Ability

  # This gets a list of all of the tables Names like ["Order", "Pen", "User"]
  # ActiveRecord::Base.connection.tables.map do |model|   model.capitalize.singularize.camelize end

 
  def initialize(user)    

    return if user.nil? 
    
    alias_action :manage, :to => :all
    alias_action :read, :create, :update, :to => :write
    alias_action :destroy, :to => :delete

    user.roles.each do |role|
      role.permissions.each do |permission|
        if permission.subject_class == "all"
          can permission.action.to_sym, permission.subject_class.to_sym          
        else          
          can permission.action.to_sym, permission.subject_class.constantize        
        end
      end
    end
  end

  def self.can_user_do_action(user, class_name, action)


    user.roles.each do |role|

      return true if role.permissions.where("subject_class = ? or (subject_class = ? and (action = ? or action = ?))", "all", class_name, action, "all").count > 0

    end

    return false

  end

  # def initialize(user)
  #   # Define abilities for the passed in user here. For example:
  #   #
  #   user ||= User.new # guest user (not logged in)
    
  #   # can :read, :all
  #   # can :create, [:objectName]
  #   # can :update, [:objectName]
  #   # can :destory, [:objectName]
  #   # can :manage, [:objectName]

  #   # super_admin - can manage anything
  #   # inventory_admin - can manage inventory
  #   # sales_member - can manage orders
  #   # feed_mill_amdin - can manage feed mill queue
  #   # feed_mill_worker - can update feed mill queue
  #   can :read, :all
    
  #   if user.role? :inventory_admin
  #     inventory_admin_rules
  #   end
  #   if user.role? :sales_member
  #     sales_member_rules
  #   end     
  #   if user.role? :pen_creator
  #     pen_creator_rules
  #   end
  #   # greater permissions should be last because if cannot is used it overrides previous permissions
  #   if user.role? :super_admin
  #     can :manage, :all
  #   end  

  # end

  # def inventory_admin_rules
  #   can :manage, [Inventory]
  # end

  # def sales_member_rules
  #     can :manage, [Pen]    
  # end

  # def pen_creator_rules
  #   can :create, ["Pen".constantize]
  #   can :update, [Pen]
  #   cannot :destroy, [Pen]
  # end
end

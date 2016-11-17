class RolesController < ApplicationController
  # before_action :set_role, only: [:show, :edit, :update, :destroy] # Handled by load_and_authorize_resource

  load_and_authorize_resource
  before_action :require_user
  respond_to :html, :json

  before_action :set_menu_expands #for setting which menu items are expanded

  def set_menu_expands
    @menu_expands = ['menuSettingsDropdown']
  end

  def index
    @roles = Role.search(params[:search]).order(sort_column + " " + sort_direction).page params[:page]
    respond_with(@roles)
  end

  def show    
    respond_with(@role)
  end

  def new
    # @role = Role.new # Handled by load_and_authorize_resource
    respond_with(@role)
  end

  def edit
    check_super_admin
  end

  def create
    # @role = Role.new(role_params) # Handled by load_and_authorize_resource
    set_permissions
    
    flash[:success] = _('Role was successfully created.') if @role.save    
    respond_with(@role) do |format|
      format.html { redirect_to edit_role_path(@role) }
    end
  end

  def update        
    check_super_admin
    set_permissions

    flash[:success] = _('Role was successfully updated.') if @role.update(role_params)
    respond_with(@role, location: edit_role_path(@role))     
    
  end

  def destroy
    check_super_admin

    @role.destroy
    respond_with(@role)
  end

  private
    # Handled by load_and_authorize_resource
    # def set_role
    #   @role = Role.find(params[:id])
    # end  
    def check_super_admin
      if @role.is_super_admin
      flash[:info] = "You can't change the Super Admin"
      redirect_to action: 'index'
    end

    end
    def set_permissions
      
      if params["role"]["permissions"] != nil
        selected_permissions = []
        params["role"]["permissions"].each do |class_name, class_perms|
          class_perms.each do |action, on|
            perm = Permission.where(subject_class: class_name, action: action).first
            selected_permissions.push(perm) if !perm.nil?
          end              
        end
        @role.permissions.clear
        @role.permissions = selected_permissions    
      end      
    end

    def role_params
      rp = params.require(:role).permit(:name, :original_updated_at)
      
      rp[:recieves_order_more_notifications] = params[:role][:recieves_order_more_notifications] == "on"
      rp[:recieves_system_notifications] = params[:role][:recieves_system_notifications] == "on"
      rp[:can_print_batch_sheets] = params[:role][:can_print_batch_sheets] == "on"
      rp[:can_upload_rations] = params[:role][:can_upload_rations] == "on"
      rp[:can_recieve_internal_feed_orders] = params[:role][:can_recieve_internal_feed_orders] == "on"
    
      return rp
    end

    def sort_column
        params[:sort_column].blank? ? "name" : params[:sort_column]
    end
end

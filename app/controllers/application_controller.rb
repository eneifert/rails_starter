class ApplicationController < ActionController::Base
  helper_method :sort_column, :sort_direction

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_gettext_textdomain
  before_action :set_gettext_locale
  before_action :set_menu_expand #for setting which menu items are expanded
  before_action :check_maintenance
  
  check_authorization 

  rescue_from CanCan::AccessDenied do |exception|
    # flash["success"] = exception.message    
    # flash["info"] = exception.message    
    # flash["warning"] = exception.message        
    flash['danger'] = _("You are not authorized to do this action")

    redirect_to :root
    # redirect_to url_for :controller => params["controller"]
  end

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  before_filter :set_current_user
  before_filter :save_last_index_url

  def check_maintenance
    if File.exists?("public/maintenance.html")
      render file: "public/maintenance.html", layout: false
    end
  end

  def save_last_index_url    
    skip_ajax_requests = ["/supplier_search", "/client_searches", "/inventory_transports/get_stats", "/bulk_discounts/types_for_category", "/supplier_search/patents", "/feed_mill_jobs/ajax_update_statuses", "/purchase_orders/for_product_types"]
    
    if action_name == "index" && controller_name != "notifications" && !skip_ajax_requests.include?(request.path)
            
      session[:last_index_url] = request.fullpath
    end
  end

  def set_current_user    
    User::current_user = current_user
  end

  def pjax_layout
    'pjax'
  end

  def record_not_found
    render '/shared/not_found'
  end

  protected  
    def set_menu_expand
      @menu_expands = []
    end

    def default_url_options(options = {})
      { locale: I18n.locale }.merge options
    end
    
    # Reloads the translations in development. Production should be done in the initializer
    def set_gettext_textdomain    
      FastGettext.reload! if Rails.env.development?
    end

    def require_user  	
      session.delete(:return_to)
      if current_user == nil
        session[:return_to] = request.fullpath
        redirect_to new_user_session_path
      end
    end   

    def after_sign_in_path_for(resource)
      session[:return_to] || root_path
    end

    #derive the model name from the controller. egs UsersController will return User
    def self.permission
      return name = self.name.gsub('Controller','').singularize.split('::').last.constantize.name rescue nil
    end
   
    def current_ability
      @current_ability ||= Ability.new(current_user)
    end
   
    #load the permissions for the current user so that UI can be manipulated
    def load_permissions
      @current_permissions = []

      return if current_user.nil? || current_user.roles.nil?

      current_user.roles.each do |role|
        @current_permissions |= role.permissions.collect{|i| [i.subject_class, i.action]}
      end

      # @current_permissions = current_user.role.permissions.collect{|i| [i.subject_class, i.action]}
    end

  private
    
    # override these by putting them in a specific controller like feed_mill_jobs_controller
    def sort_column
      params[:sort_column].blank? ? "id" : params[:sort_column]
    end
    
    def sort_direction
      %w[asc desc].include?(params[:sort_direction]) ? params[:sort_direction] : "desc"
    end

end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_gettext_textdomain
  before_action :set_gettext_locale
  
  # Reloads the translations in development. Production should be done in the initializer
  def set_gettext_textdomain    
    FastGettext.reload! if Rails.env.development?
  end

  def require_admin  	
    session.delete(:return_to)
    if current_admin == nil
      session[:return_to] = request.fullpath
      redirect_to new_admin_session_path
    end
  end   

  def after_sign_in_path_for(resource)
    session[:return_to] || root_path
  end

end

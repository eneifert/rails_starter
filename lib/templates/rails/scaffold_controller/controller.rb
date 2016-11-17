<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController

  load_and_authorize_resource
  before_filter :load_permissions # call this after load_and_authorize else it gives a cancan error
  before_action :require_user
  respond_to :html, :json

<% unless options[:singleton] -%>
  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
    respond_with(@<%= plural_table_name %>)
  end
<% end -%>

  def show    
    respond_with(@<%= singular_table_name %>)
  end

  def new    
    respond_with(@<%= singular_table_name %>)
  end

  def edit
  end

  def create    
        
    if @<%= orm_instance.save %>    
      <%= "flash[:success] = _('#{class_name} was successfully created.')" %> 
      respond_with(@<%= singular_table_name %>, location: edit_<%= singular_table_name %>_path(@<%= singular_table_name %>)) 
    else
      respond_with(@<%= singular_table_name %>)
    end  
  end

  def update    
    <%= "flash[:success] = _('#{class_name} was successfully updated.')" %> if @<%= singular_table_name %>.update(<%= singular_table_name %>_params)    
    respond_with(@<%= singular_table_name %>, location: edit_<%= singular_table_name %>_path(@<%= singular_table_name %>)) 
  end

  def destroy
    res = @<%= orm_instance.destroy %>
    flash[:notice] = _('<%= "#{class_name} was successfully deleted." %>') if res 
    respond_with(@<%= singular_table_name %>)
  end

  private
    # Handled by load_and_authorize_resource
    # def set_<%= singular_table_name %>
    #   @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    # end
  
    def <%= "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params[:<%= singular_table_name %>]
      <%- else -%>
      params.require(:<%= singular_table_name %>).permit(:original_updated_at, <%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end    
end
<% end -%>

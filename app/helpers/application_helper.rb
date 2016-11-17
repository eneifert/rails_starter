module ApplicationHelper
	def link_to_add_fields(name, f, association)
	    new_object = f.object.send(association).klass.new
		
	    # link_to_add_fields_for_object(name, new_object, association)
		id = new_object.object_id
	    fields = f.fields_for(association, new_object, child_index: id) do |builder|
	      render(association.to_s.singularize + "_fields", f: builder)
	    end
	    link_to("<i class='fa fa-plus-circle space-right'></i> #{name}".html_safe, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  	end

  	def link_to_add_fields_for_object(name, new_object, association)
	    
	    id = new_object.object_id
	    fields = fields_for(association, new_object, child_index: id) do |builder|
	      render(association.to_s.singularize + "_fields", f: builder)
	    end
	    link_to("<i class='fa fa-plus-circle space-right'></i> #{name}".html_safe, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  	end

  	def checkbox_checked(value)
  		return "checked='checked'" if value != nil && value  		
  	end  	

  	def get_index_params
  		params.except(:controller, :action, :sort_direction, :locale, :sort_column, :utf8)
  	end

  	def sortable(column, title = nil, removed_params={})
  	  
  	  if params[:plain_layout] == "true"
  	  	return title || column.titleize
  	  end
  	  
  	  if column == "product_types.name" && I18n.locale != :en  	  	
  	  	column = "product_types.name_ru"
  	  end
	  title ||= column.titleize
	  
	  css_class = column == sort_column ? "current #{sort_direction}" : nil
	  direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
	  link_to title, {:sort_column => column, :sort_direction => direction, :search => params[:search]}.merge(get_index_params.except(:sort_column, :sort_direction)), {:class => css_class}
	end

	def current_url_for_locale(locale)			

		tmp = url_for( :locale => locale ) 
		if !request.query_string.blank?
		 tmp += '?' + request.query_string
		end
		
		return tmp
	end

	def pretty_datetime(dt, to_current_timezone=false)		
		return "" if dt.nil?

		dt = dt.to_datetime

		if to_current_timezone
			dt = dt.in_time_zone
		end

		if I18n.locale != :en
			return Russian::strftime(dt, "%b %d %R")
		end
		dt.strftime("%b %d %R")
	end

	def safe_round(value, round_zero=true)
		return 0 if value.nil?

		begin
			
			tmp = value.to_d.round(2)
			
			# sometimes we have strings that round to zero. If round_zero is false it will return the string
			if tmp == 0 && !round_zero
				return value
			else
				return tmp
			end
		rescue
		end

		return value
	end


	def datetime_with_day(dt)
		return "" if dt.nil?
		if I18n.locale != :en
			return Russian::strftime(dt, "%A %B %e %R")
		end
		dt.strftime("%A %B %e %R")
	end

	def nil_or_undefined?(value)
		return defined?(value).nil? || value.nil?		
	end
end

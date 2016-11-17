
module OptimisticLocking
  extend ActiveSupport::Concern
 
  included do
    validate :handle_conflict, on: :update   
    attr_writer :original_updated_at    
  end  

	def original_updated_at
	  @original_updated_at || updated_at.to_f
	end


	def handle_conflict
			
	  if @conflict || updated_at.to_f > original_updated_at.to_f
	    @conflict = true
	    @original_updated_at = nil
	    errors.add :base, _("This record changed while you were editing. Take these changes into account and submit it again.")
	    changes.each do |attribute, values|
	      errors.add attribute, "was #{values.first}"
	    end
	  end
	end


  # methods defined here are going to extend the class, not the instance of it
  module ClassMethods
   
  end
end


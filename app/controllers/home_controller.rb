class HomeController < ApplicationController	
	before_action :require_user
	skip_authorization_check

	def index
		
	end

	def todo
		
	end
end

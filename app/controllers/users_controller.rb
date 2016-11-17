class UsersController < ApplicationController	
	before_action :require_user	  	
  	load_and_authorize_resource

  	before_action :set_menu_expands #for setting which menu items are expanded

	def set_menu_expands
	@menu_expands = ['menuSettingsDropdown']
	end

	# GET /users
	# GET /users.json
	def index
		@users = User.search(params[:search]).order(sort_column + " " + sort_direction).page params[:page]
	end

	# GET /users/1
	# GET /users/1.json
	def show
	end

	# GET /user/new
	def new
		# @user = User.new #set in load_and_authorize_resource
	end

	# GET /users/1/edit
	def edit
	end

	# POST /users
	# POST /users.json
	def create		
		# @user = User.new(user_params) #set in load_and_authorize_resource
		set_roles

		respond_to do |format|
		  if @user.save
		    format.html { redirect_to users_path, :flash => { :success => _('User user was successfully created.') } }
		    format.json { render :index, status: :created, location: users_path }
		  else
		    format.html { render :new }
		    format.json { render json: @user.errors, status: :unprocessable_entity }
		  end
		end
	end

	# PATCH/PUT /users/1
	# PATCH/PUT /users/1.json
	def update
		set_roles

		respond_to do |format|
		  if @user.update(user_params)
		    format.html { redirect_to edit_user_path(@user), :flash => { :success => _('User user was successfully updated.') } }
		    format.json { render :index, status: :ok, location: users_path }
		  else
		    format.html { render :edit }
		    format.json { render json: @user.errors, status: :unprocessable_entity }
		  end
		end
	end

	# DELETE /users/1
	# DELETE /users/1.json
	def destroy
		@user.destroy
		respond_to do |format|
		  format.html { redirect_to users_url, notice: _('User user was successfully destroyed.') }
		  format.json { head :no_content }
		end
	end

	private	
	# Never trust parameters from the scary internet, only allow the white list through.
	def set_roles		
      selected_roles = []

      if !params["user"]["roles"].nil?
	      params["user"]["roles"].each do |id, on|      	        
	      	selected_roles.push(Role.find(id.to_i))        
	      end
	  end
      @user.roles = selected_roles    
    end

	def user_params
	  res = params.require(:user).permit(:location_id, :email, :password, :name, :original_updated_at)
	  if res[:password].blank? 
    	res.delete(:password)
       end
       return res
	end

		def sort_column
	      params[:sort_column].blank? ? "name" : params[:sort_column]
	    end
end

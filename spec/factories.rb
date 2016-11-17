FactoryGirl.define do  

	factory :permission do
	   name 'All'
	   subject_class "all"
	   action "all"	   
	end

	factory :role do
	    name "Super Admin"
      recieves_order_more_notifications true
      recieves_system_notifications true	    
	    permissions {[FactoryGirl.create(:permission)]}
	end

	factory :user do
		email "admin@example.com"
		password "password"
		password_confirmation "password"
    	roles {[FactoryGirl.create(:role)]}
	end
	
end
require 'rails_helper'
# require 'ruby-debug'
include Warden::Test::Helpers

RSpec.describe "home page", :type => :feature do
  before :each do    
    # Just clean the db first if it didn't get cleaned right last time
    # DatabaseCleaner.clean
    # DatabaseCleaner.start    
    @user = create(:user)
    login_as @user, scope: :user        
  end
  
  # after :each do
  #   # DatabaseCleaner.clean
  # end

  it "can reach the home page after logging in" do	    
  	# Capybara.default_driver = :selenium    	  	 
  	
    # visit root_path
    # visit new_user_session_path
    # within("#new_user") do
    #   fill_in 'Email', :with => 'admin@example.com'
    #   fill_in 'Password', :with => 'password'
    # end    
    # click_on 'Login'        

    visit root_path    
    expect(page).to have_content 'Dashboard'
  end
end
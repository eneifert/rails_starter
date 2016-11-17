# Load the Rails application.
require File.expand_path('../application', __FILE__)

Rails.application.configure do
	log_file_for_week = Date.today.beginning_of_week.strftime("week_of_%m_%d_%Y")
   config.logger = Logger.new(File.dirname(__FILE__) + "/../log/#{Rails.env}_#{log_file_for_week}.log")
end

# Initialize the Rails application.
Rails.application.initialize!


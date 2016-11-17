# BusinessTime::Config.load("#{Rails.root}/config/business_time.yml")

# # or you can configure it manually:  look at me!  I'm Tim Ferriss!
# BusinessTime::Config.beginning_of_workday = "8:30 am"
# BusinessTime::Config.end_of_workday = "4:30 pm"

# BusinessTime::Config.holidays << Date.parse("May 28th, 2015")

# This is now set in the DB
# WorkingHours::Config.working_hours = {
# 	mon: {'08:00' => '12:00', '12:30' => '17:00'},
# 	tue: {'08:00' => '12:00', '12:30' => '17:00'},
# 	wed: {'08:00' => '12:00', '12:30' => '17:00'},
# 	thu: {'08:00' => '12:00', '12:30' => '17:00'},
# 	fri: {'08:00' => '12:00', '12:30' => '17:00'}
# }

# Configure timezone (uses activesupport, defaults to UTC)
WorkingHours::Config.time_zone = 'Almaty'

# Configure holidays
WorkingHours::Config.holidays = []
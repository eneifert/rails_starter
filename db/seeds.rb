

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Run with the following commands
# rake db:seed
# rake db:seed RAILS_ENV="production"


puts "Running seed data"
if User.count == 0
	puts "Creating admin@example.com [password]"
	User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
end

if Role.count == 0
  puts "Creating Roles"
  role = Role.create!(name: 'Super Admin', recieves_order_more_notifications: true, recieves_system_notifications: true)
  
  #create a universal permission
  perm = Permission.create!(name: 'All', subject_class: "all", action: "all")
  
  user = User.where(email: 'admin@example.com').first
  user.roles << role       

  role.permissions << perm      
  
end


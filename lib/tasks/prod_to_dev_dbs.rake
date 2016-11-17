task :prod_db_to_dev do
	
	puts "Copying Production DB to development db"
	puts "Copying Production DB to data.yml"
	sh "bundle exec rake db:data:dump RAILS_ENV=production"
	
	puts "Loading the data.yml file to development"
	sh "bundle exec rake db:data:load RAILS_ENV=development"
	puts "Done"
end

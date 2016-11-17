# config valid only for current version of Capistrano
lock '3.5.0'

# require "whenever/capistrano"

set :application, 'encompass_maps'
set :repo_url, 'https://eneifertdev1:usedforreleasingsoftware@github.com/eneifert/encompass_maps.git'
set :deploy_to, '/home/eneifert/webapps'

set :app_path, -> { fetch(:env_app_path) }
set :full_app_path, -> { "#{deploy_to}/#{fetch(:env_app_path)}" }

set :maintenance, false

role :web, "eneifert@wf-178-79-142-229.webfaction.com"
role :app, "eneifert@wf-178-79-142-229.webfaction.com"
role :db,  "eneifert@wf-178-79-142-229.webfaction.com", :primary => true 

namespace :webfaction do 

	task :deploy do 
		on roles(:app) do [
			{dir: "encompass_maps", env: "production", branch: "master"}
			].each do |item|

				tmp_deploy_to = "#{deploy_to}/#{item[:dir]}"
				tmp_full_app_path = "#{tmp_deploy_to}/encompass_maps"				

				# set up the path variables
				env_var_cmd = "cd #{tmp_deploy_to} && export PATH=$PWD/bin:$PATH && export GEM_HOME=$PWD/gems && export RUBYLIB=$PWD/lib &&"	      	      

				if ENV['maintenance']
					execute "#{env_var_cmd} cd #{tmp_full_app_path} && rake start_maintenance"
				end				

				# pull the code and get rid of any changes						
				execute "cd #{tmp_full_app_path} && git config --global user.email \"eneifertdev1@gmail.com\""
				execute "cd #{tmp_full_app_path} && git config --global user.name \"Eneifert Dev 1\""
				execute "cd #{tmp_full_app_path} && git stash save --keep-index"
				
				begin
					execute "cd #{tmp_full_app_path} && git stash drop"	
				rescue Exception => e
					
				end
				
				execute "cd #{tmp_full_app_path} && git pull #{repo_url}"

				# execute "cd #{tmp_full_app_path} && git fetch #{repo_url}"
				execute "cd #{tmp_full_app_path} && git checkout #{item[:branch]}"

				# update the gems
				execute "#{env_var_cmd} cd #{tmp_full_app_path} && bundle install"

				# migrate the db
				execute "#{env_var_cmd} cd #{tmp_full_app_path} && rake db:migrate RAILS_ENV=#{item[:env]}"
				execute "#{env_var_cmd} cd #{tmp_full_app_path} && rake db:seed RAILS_ENV=#{item[:env]}"

				execute "#{env_var_cmd} cd #{tmp_full_app_path} && rake permissions:permissions RAILS_ENV=#{item[:env]}"

				#udpate cron tasks
				execute "#{env_var_cmd} cd #{tmp_full_app_path} && bundle exec whenever --set 'environment=#{item[:env]} & path=#{item[:dir]}' --update-crontab"

				# bundle the assets
				execute "#{env_var_cmd} cd #{tmp_full_app_path} && RAILS_ENV=#{item[:env]} bundle exec rake assets:precompile"

				# END maintenance
				execute "#{env_var_cmd} cd #{tmp_full_app_path} && rake end_maintenance"
				
				# restart the server
				execute "$HOME/webapps/#{item[:dir]}/nginx/sbin/nginx -p $HOME/webapps/#{item[:dir]}/nginx/ -s reload"

			end
	    end		
	end

end

namespace :deploy do

  puts "============================================="
  puts "SIT BACK AND RELAX WHILE CAPISTRANO ROCKS ON!"
  puts "============================================="

end


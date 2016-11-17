# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "/home/encompass_maps/webapps/#{path}/encompass_maps/log/#{Date.today.strftime("month_of_%m_%Y")}_cron.log"

job_type :plain_cmd, ':task'

class WebFactionRunner
	def self.format_runner_cmd(app_path, environment, task)
		cmd = "cd /home/eneifert/webapps/{app_path}/encompass_maps && export GEM_HOME=/home/eneifert/webapps/{app_path}/gems && export PATH=/home/eneifert/webapps/{app_path}/bin:/usr/local/bin:$PATH && export RUBYLIB=/home/eneifert/webapps/{app_path}/lib && rails runner -e {environment} '{task}'"
		return my_hash_format(cmd, {"app_path" => app_path, "environment" => environment, "task" => task })  
	end

	def self.format_cmd(app_path, environment, task)
		cmd = "cd /home/eneifert/webapps/{app_path}/encompass_maps && export GEM_HOME=/home/eneifert/webapps/{app_path}/gems && export PATH=/home/eneifert/webapps/{app_path}/bin:/usr/local/bin:$PATH && export RUBYLIB=/home/eneifert/webapps/{app_path}/lib && {task}"
		return my_hash_format(cmd, {"app_path" => app_path, "environment" => environment, "task" => task })  
	end

	def self.my_hash_format(my_string, hash)   
	  	tmp = my_string
		hash.each do |k, v|
			if tmp.include? "{#{k}}"
				tmp = tmp.gsub!("{#{k}}", v.to_s)
			end		
		end

		return tmp	
	end 
end

# every 1.day, :at => '2:30 am' do    
#   command WebFactionRunner::format_runner_cmd(path, environment, "SystemNotification.check_for_orders_not_picked_up")    
# end

# # FOR THIS TO WORK do the following
# # 1) SSH into the server
# # 2) nano $HOME/.pgpass
# # 3) Add a new line containing *:*:database_name:database_user:password
# # 4) chmod 600 $HOME/.pgpass
# # 5) Then create a dir for the backups: mkdir $HOME/db_backups
# # Then updating the crontab with the following should work
# every 1.day, :at => '1:00 am' do 

# 	if environment == "bishkek_production"

# 		plain_cmd "/usr/local/pgsql/bin/pg_dump -Fc -b -U dn_db_user bishkek_dutch_nature_db > $HOME/db_backups/bishkek/bishkek_dutch_nature_db-$(date +\%Y\%m\%d).sql"

# 		# delete any files older than 25 days so it doesn't fill up
# 		plain_cmd 'find $HOME/db_backups/bishkek* -mtime +50 -exec rm {} \;'
# 	end
# end

# View crontab: crontab -l

# /usr/local/pgsql/bin/pg_dump -Fc -b -U dn_db_user bishkek_dutch_nature_db > $HOME/db_backups/bishkek/bishkek_dutch_nature_db-$(date +\%Y\%m\%d).sql 2>> $HOME/logs/user/bishkek_dutch_nature_db.log
# /usr/local/pgsql/bin/pg_dump -Fc -b -U dn_db_user bishkek_dutch_nature_db > $HOME/db_backups/bishkek/bishkek_dutch_nature_db-$(date +\%Y\%m\%d).sql >> /home/eneifert/webapps/bishkek_dutch_nature/dutch_nature/log/month_of_10_2016_cron.log 2>&1

# pg_restore -c -Fc -U dn_db_user -d beta_dutch_nature_db $HOME/db_backups/bishkek/bishkek_dutch_nature_db-20161004.sql


# Learn more: http://github.com/javan/whenever

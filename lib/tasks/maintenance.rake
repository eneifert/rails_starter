task :start_maintenance do
	if File.exists?("public/_maintenance.html")
		File.rename("public/_maintenance.html", "public/maintenance.html")
	end
end

task :end_maintenance do
	if File.exists?("public/maintenance.html")
		File.rename("public/maintenance.html", "public/_maintenance.html")
	end
end
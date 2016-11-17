class String
  
  def my_format(*args)   
  	tmp = self
	args.each_with_index do |arg, i|
		tmp = tmp.gsub!("{#{i}}", arg)
	end

	return tmp	
  end

  def my_hash_format(hash)   
  	tmp = self
	hash.each do |k, v|
		if tmp.include? "{#{k}}"
			tmp = tmp.gsub!("{#{k}}", v.to_s)
		end		
	end

	return tmp	
  end  

end
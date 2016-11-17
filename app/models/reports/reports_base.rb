class ReportsBase

	  def self.clean_evil_sql(sql)
      return sql if sql.nil?
      
      evil = ['select', 'insert', 'update', 'delete']
      res = sql.to_s.mb_chars.downcase.to_s
      evil.each do |i|
        res = res.gsub(i, '')
      end
      return res
    end

    def self.escape_sql_param(*param)
    	ActiveRecord::Base::send(:sanitize_sql_array, (["?"] + param))
    end

    def self.escape_sql(clause, *params)
    	ActiveRecord::Base::send(:sanitize_sql_array, params.empty? ? clause : ([clause] + params))
    end


end
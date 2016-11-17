 source 'http://rubygems.org'

# used for setting the ruby version. EX:
# C:\Users\Eric\Documents\GitHub\kamkorduk> pik list
# * 193: ruby 1.9.3p484 (2013-11-22) [i386-mingw32]
#   200: ruby 2.0.0p481 (2014-05-08) [i386-mingw32]
# C:\Users\Eric\Documents\GitHub\kamkorduk> pik 200
# C:\Users\Eric\Documents\GitHub\kamkorduk> pik list
#   193: ruby 1.9.3p484 (2013-11-22) [i386-mingw32]
# * 200: ruby 2.0.0p481 (2014-05-08) [i386-mingw32]
# gem 'pik'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# group :production do
gem 'pg'

gem 'yaml_db'

# end
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
gem 'coffee-script-source', '1.8.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'pjax_rails' 
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'bundler'
gem 'devise', github: 'plataformatec/devise'
gem 'cancancan', '~> 1.10'

gem 'twitter-bootstrap-rails', :git => 'http://github.com/seyhunak/twitter-bootstrap-rails.git'
gem 'bootstrap-sass', '~> 3.2.0'
gem "font-awesome-rails"
gem 'bootstrap-generators', '~> 3.3.1'

gem 'working_hours'

gem 'whenever', :require => false

gem 'migration_data' #gives the data method on migration up and rollback on migration down

#pagination gem
gem 'kaminari'
gem 'bootstrap-kaminari-views'

group :development, :test do
  gem 'hirb'  
  gem "factory_girl_rails", "~> 4.0", :require => false
  gem 'rspec-rails', '~> 3.0'
  gem 'capybara'
  gem 'selenium-webdriver'  
  gem "chromedriver-helper", "0.0.6"
  gem 'launchy'
  gem 'database_cleaner'  
  gem 'guard-rspec', github: 'guard/guard-rspec', require: false    
  gem 'spork-rails', github: 'sporkrb/spork-rails'

  # gem 'rack-mini-profiler', require: false    
end

group :development do
  gem 'better_errors', '~> 1.1.0'
  gem "letter_opener"
  gem 'byebug'  

  gem 'capistrano', '~> 3.5.0'
  gem 'capistrano-rails'
end

gem 'exception_notification'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'                         
# gem 'bcrypt-ruby', git: 'https://github.com/codahale/bcrypt-ruby.git', :require => 'bcrypt'
# gem 'nokogiri'

# Datetime picker gmes
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.7.14'
gem 'russian', '~> 0.6.0'

# allows to save and skip callbacks
gem 'sneaky-save', git: 'git://github.com/einzige/sneaky-save.git'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'sequel'

gem "paperclip", git: 'https://github.com/thoughtbot/paperclip.git'
gem 'rmagick'

gem 'roo' #for importing excel
gem 'to_xls-rails' #for exporting excel

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'binding_of_caller'
gem 'validates_formatting_of'
gem 'tzinfo-data', platforms: [:mingw, :mswin]

#translations with fast_gettext
gem 'gettext_i18n_rails'
gem 'gettext', '>=3.0.2', :require => false, :group => :development
gem 'ruby_parser', :require => false, :group => :development
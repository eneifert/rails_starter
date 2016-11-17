require 'rubygems'
require 'spork'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'factory_girl_rails'
require 'database_cleaner'
require 'hirb'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'


  RSpec.configure do |config|

    # # rspec-expectations config goes here. You can use an alternate
    # # assertion/expectation library such as wrong or the stdlib/minitest
    # # assertions if you prefer.
    # config.expect_with :rspec do |expectations|
    #   # This option will default to `true` in RSpec 4. It makes the `description`
    #   # and `failure_message` of custom matchers include text for helper methods
    #   # defined using `chain`, e.g.:
    #   #     be_bigger_than(2).and_smaller_than(4).description
    #   #     # => "be bigger than 2 and smaller than 4"
    #   # ...rather than:
    #   #     # => "be bigger than 2"
    #   expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    # end

    # # rspec-mocks config goes here. You can use an alternate test double
    # # library (such as bogus or mocha) by changing the `mock_with` option here.
    # config.mock_with :rspec do |mocks|
    #   # Prevents you from mocking or stubbing a method that does not exist on
    #   # a real object. This is generally recommended, and will default to
    #   # `true` in RSpec 4.
    #   mocks.verify_partial_doubles = true
    # end  

    config.include FactoryGirl::Syntax::Methods
    

    

  config.before(:suite) do
    DatabaseCleaner.clean_with(:transaction)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  

    # config.before(:suite) do      
    #   DatabaseCleaner.clean_with :deletion  # clean DB of any leftover data
    #   # may not work with selenium? May need truncation
    #   DatabaseCleaner.strategy = :deletion # rollback transactions between each test      
    # end

    # config.before(:each) do
    #   DatabaseCleaner.start
    # end

    # config.after(:each) do
    #   DatabaseCleaner.clean
    # end


    # # Note can't use transaction with selenium
    # # DatabaseCleaner[:active_record].strategy = :transaction
    # DatabaseCleaner[:active_record].strategy = :truncation

    # config.around(:each) do |example|
    #   DatabaseCleaner.cleaning do
    #     example.run
    #   end
    # end
  end


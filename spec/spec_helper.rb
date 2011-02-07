require 'rubygems'
require 'active_record'
require 'rspec'

require 'ruby-debug'
Debugger.start

require File.expand_path(File.dirname(__FILE__) + '../../lib/acts_as_versioned.rb')
require File.expand_path(File.dirname(__FILE__) + '/models.rb')
require File.expand_path(File.dirname(__FILE__) + '/migrations.rb')

db = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.configurations = { :mysql => db['mysql'] }
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:mysql])

RSpec.configure do |config|
	config.mock_with :rspec
end

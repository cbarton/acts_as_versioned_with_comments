require 'rubygems'
require 'active_record'
require 'rspec'

require 'ruby-debug'
Debugger.start

require File.expand_path(File.dirname(__FILE__) + '../../lib/acts_as_versioned.rb')

db = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.configurations = { :mysql => db['mysql'] }
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:mysql])

require File.expand_path(File.dirname(__FILE__) + '/models.rb')
require File.expand_path(File.dirname(__FILE__) + '/migrations.rb')

RSpec.configure do |config|
	config.mock_with :rspec
	config.before(:all) { 
		Post.create_versioned_table unless Post.versioned_class.table_exists?
		LockedPost.create_versioned_table unless LockedPost.versioned_class.table_exists?
	}
end

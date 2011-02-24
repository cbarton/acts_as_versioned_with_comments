require 'rubygems'
require 'active_record'
require 'rspec'

require 'ruby-debug'

require File.expand_path(File.dirname(__FILE__) + '../../lib/acts_as_versioned.rb')

db = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.configurations = { :mysql => db['mysql'] }
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:mysql])

require File.expand_path(File.dirname(__FILE__) + '/models.rb')
require File.expand_path(File.dirname(__FILE__) + '/schema.rb')



RSpec.configure do |config|
	config.mock_with :rspec
	config.before(:all) { 
		[Post, LockedPost, Widget, Landmark].each do |klass|
			klass.create_versioned_table
		end
	}
	config.after(:all) {
		[Post, LockedPost, Widget, Landmark].each do |klass|
			klass.drop_versioned_table if klass.versioned_class.table_exists?
		end
	}
end

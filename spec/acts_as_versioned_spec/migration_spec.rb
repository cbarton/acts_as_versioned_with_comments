require 'spec_helper'

if ActiveRecord::Base.connection.supports_migrations?
	class Thing < ActiveRecord::Base
		acts_as_versioned
	end
end

describe 'ActsAsVersionedModel' do
	before(:all) do 
		ActiveRecord::Migrator.up(File.dirname(__FILE__) + '/../migrations/')
		@t = Thing.create :title => 'blah', :price => 123.45, :type => 'Thing'
	end

	describe '#create_versioned_table' do
		it 'should create the versioned table and model' do
			@t.versions.size.should ==(1)
			@t.price.should == @t.versions.first.price
			@t.title.should == @t.versions.first.title
			@t[:type].should == @t.versions.first[:type]
		end

		it 'should preserve the columns' do	
			Thing::Version.columns.find { |c| c.name == "price" }.precision.should == (7)	
			Thing::Version.columns.find { |c| c.name == "price" }.scale.should == (2)	
		end
	end

	after(:all) do
		ActiveRecord::Migrator.down(File.dirname(__FILE__) + '/../migrations/')
	end
end

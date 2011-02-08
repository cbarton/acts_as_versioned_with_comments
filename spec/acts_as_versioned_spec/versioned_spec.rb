require 'spec_helper'

describe ActiveRecord::Acts::Versioned do

	MIGRATIONS = [CreatePosts, CreateLockedPosts]

	before(:all) do
		MIGRATIONS.each { |migration| migration.up }
	end

	it 'should make the correct versioned class' do
		Post.versioned_class_name.should =="Version"
		Post.versioned_class.should == Post::Version
	end

	describe 'the actual model' do
		before(:each) do 
			@post = Post.create!(:title => "My first post", :public => true)
		end

		it 'should save a versioned copy' do
			@post.versions.count.should ==(1)
			@post.version.should ==(1)
			@post.versions.first.should be_instance_of Post.versioned_class
		end

		it 'should save without revision' do
			count = @post.versions.count
			
			@post.save_without_revision
			
			@post.without_revision do
				@post.update_attributes(:title => "My second post")
			end

			count.should ==@post.versions.count
		end	

		it 'should rollback to a valid version' do
			@post.update_attributes(:title => "My other post")
			@post.reload

			@post.revert_to!(3).should be_false

			@post.revert_to!(1)
			@post.version.should ==(1)
			@post.title.should =="My first post"
			
			@post.revert_to!(@post.versions.last)
			@post.version.should ==(2)
			@post.title.should =="My other post"
		end

		it 'should not rollback with another instance' do
			other_post = Post.new(:title => "My other post")

			@post.revert_to!(other_post).should be_false
		end

		after(:each) do 
			@post.versions.delete_all
		end
	end
	
	describe 'the versioned model' do
		
		before(:each) do 
			@post = Post.create!(:title => "My first post", :public => true)
		end
	
		it 'should keep special methods' do
			@post.on_the_wall?.should be_true
			@post.versions.first.on_the_wall?.should be_true
			
			locked_post = LockedPost.create!(:title => "My first locked post", :lock_version => 5)
			locked_post.hello_world.should == "Hello World"
			locked_post.versions.first.hello_world.should =="Hello World"
		end
		
		after(:each) do 
			@post.versions.delete_all
			@post.destroy
		end
	end

	describe 'the actual model with options' do
		
		before(:each) do
			@locked_post = LockedPost.create!(:title => "My first locked post", :lock_version => 5)
		end

		it 'should save a versioned copy' do
			other_page = LockedPost.create!(:title => "other")
			other_page.new_record?.should be_false

			other_page.versions.size.should ==(1)
			other_page.versions.first.should be_instance_of(LockedPost.versioned_class)
		end

		after(:each) do
			@locked_post.versions.delete_all
			@locked_post.destroy
		end
	end

	after(:all) do
		MIGRATIONS.each { |migration| migration.down }
	end
end

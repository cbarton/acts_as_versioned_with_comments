require 'spec_helper'

describe ActiveRecord::Acts::Versioned do

	before(:all) do
		CreatePosts.up
		Post.create_versioned_table
		@post = Post.create!(:title => "My first post", :public => true)
	end

	it 'should make the correct versioned class' do
		Post.versioned_class_name.should =="Version"
		Post.versioned_class.should == Post::Version
	end

	describe 'creates the versioned model' do

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
		
	end

	describe 'the versioned model' do
	
		it 'should keep special methods' do
			@post.public = false
			@post.save!

			@post.public.should be_false
			@post.versions.first.public.should be_true
		end
	end

	after(:all) do
		Post.drop_versioned_table
		CreatePosts.down
	end
end

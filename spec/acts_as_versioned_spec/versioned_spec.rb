require 'spec_helper'

describe ActiveRecord::Acts::Versioned do

	it 'should make the correct versioned class' do
		Post.versioned_class_name.should =="Version"
		Post.versioned_class.should == Post::Version
	end

	it 'should track altered attributes default values' do
		Post.track_altered_attributes.should be_false
		LockedPost.track_altered_attributes.should be_true
		SpecialLockedPost.track_altered_attributes.should be_true
	end

	it 'should track altered attributes' do
		locked_post = LockedPost.create!(:title => "locked post")
		locked_post.lock_version.should ==(1)
		locked_post.versions.count.should ==(1)

		locked_post.body = "locked body"
		locked_post.save_version?.should be_false
		locked_post.save
		locked_post.lock_version.should ==(2)
		locked_post.versions(true).size.should ==(1)
		
		locked_post.title = "updated locked post"
		locked_post.save_version?.should be_true
		locked_post.save
		locked_post.lock_version.should ==(3)
		locked_post.versions(true).size.should ==(1)

		locked_post.title = "updated locked post again"
		locked_post.save_version?.should be_true
		locked_post.save
		locked_post.lock_version.should ==(4)
		locked_post.versions(true).size.should ==(2)
	end

	it 'should be scoped' do
		l = LockedPost.first
		l.versions.where('title like ?', "%#{l.title}%").count.should ==(1)
		l.versions.find_by_lock_version(l.lock_version).should == l.versions.latest
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

		it 'should accept the if option' do
			@post.version.should ==(1)
			Post.on_the_wall = false
			@post.save
			@post.version.should==(1)
			Post.on_the_wall = true
		end

		it 'should accept the if condition with aliasing' do
			Post.class_eval do
				def new_on_the_wall; title.starts_with?('a'); end
				alias_method :old_on_the_wall, :on_the_wall?
				alias_method :on_the_wall?, :new_on_the_wall
			end

			post = Post.create!(:title => "post me")
			post.version.should ==(1)
			post.versions.count.should ==(1)

			post.update_attribute(:title, "nother post for me")
			post.version.should ==(1)
			post.versions.count.should ==(1)

			post.update_attribute(:title, "another post for me")
			post.version.should ==(2)
			post.versions.count.should ==(2)

			Post.class_eval {	alias_method :on_the_wall?, :old_on_the_wall }
		end

		it 'should accept the if condition with a block' do
			old_condition = Post.version_condition
			Post.version_condition = Proc.new { |post| post.title.starts_with?("b") }

			post = Post.create!(:title => "lock post")
			post.version.should ==(1)
			post.versions.count.should ==(1)

			post.update_attribute(:title, "a block post")
			post.version.should ==(1)
			post.versions.count.should ==(1)

			post.update_attribute(:title, "block post")
			post.version.should ==(2)
			post.versions.count.should ==(2)
		
			Post.version_condition = old_condition
		end

		it 'should have no version limit' do
			@post.save
			@post.save

			5.times do |i|
				@post.update_attribute :title, "title#{i}"
				@post.title.should == "title#{i}"
				@post.version.should ==(i+2)
			end
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

		it 'should not rollback to another version' do
			@locked_post.revert_to!(@locked_post.versions.first.lock_version).should be_true
			@locked_post.revert_to!(@locked_post.versions.first).should be_true
		end

		it 'should be versionable and stale' do
			the_locked_post = LockedPost.find(@locked_post)
			@locked_post.title = "freshness"
			@locked_post.save
		
			@locked_post.versions.size.should ==(2)

			the_locked_post.title = "staleness"
			lambda { the_locked_post.save }.should raise_error(ActiveRecord::StaleObjectError)
		end
		
		it 'should have a max limit' do
			a_locked_post = LockedPost.create!(:title => "zeroith title")
			a_locked_post.update_attribute :title, "first title"
			a_locked_post.update_attribute :title, "second title"

			5.times do |i|
				a_locked_post.update_attribute :title, "title#{i}"
				a_locked_post.title.should == "title#{i}"
				a_locked_post.lock_version.should ==(i+4)
				a_locked_post.versions(true).size.should be <= 2
			end		
		end

		after(:each) do
			@locked_post.versions.delete_all
			@locked_post.destroy
		end
	end

	describe 'the actual model with sti' do
		before(:each) do 
			@sti_post = SpecialLockedPost.create!(:title => "STI post")
		end
		it 'should save a versioned copy' do
			@sti_post.new_record?.should be_false

			@sti_post.versions.size.should ==(1)
			@sti_post.versions.first.should be_instance_of(LockedPost.versioned_class)
		end
		
		it 'should not rollback to another version' do
			@sti_post.revert_to!(@sti_post.versions.first.lock_version).should be_true
			@sti_post.revert_to!(@sti_post.versions.first).should be_true
		end
	end

end

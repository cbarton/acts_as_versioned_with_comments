class CreatePosts < ActiveRecord::Migration
	def self.up
		create_table :posts do |t|
			t.string :title
			t.boolean :public
		end
		Post.create_versioned_table
	end

	def self.down 
		Post.drop_versioned_table
		drop_table :posts
	end
end

class CreateLockedPosts < ActiveRecord::Migration
	def self.up
		create_table :locked_posts do |t|
			t.string :title
			t.string :type
		end
		LockedPost.create_versioned_table
	end

	def self.down 
		LockedPost.drop_versioned_table
		drop_table :locked_posts
	end
end

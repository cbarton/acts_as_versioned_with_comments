class Post < ActiveRecord::Base
	acts_as_versioned :if => :on_the_wall? do 
		def self.included(base)
			base.cattr_accessor :on_the_wall
			@@on_the_wall = true
		end

		def on_the_wall?
			@@on_the_wall == true
		end
	end
end

# LockedPostExtension -
#		Describes the extension module for LockedPostRevision
module LockedPostExtension
	def hello_world
		"Hello World"
	end
end

# LockedPost -
#		Describes a model that has options to pass into acts_as_versioned and 
#		is locked at version 24
class LockedPost < ActiveRecord::Base
	acts_as_versioned :inheritance_column => :version_type,
										:foreign_key 				=> :post_id,
										:table_name 				=> :locked_posts_revisions,
										:class_name 				=> 'LockedPostRevision',
										:version_column			=> :lock_version,
										:limit							=> 2,
										:if_changed					=> :title,
										:extend 						=> LockedPostExtension
end

# SpecialLockedPost -
#		Describes a model that inherits from LockedPost, testing the 
#		STI capablilities of acts_as_versioned
class SpecialLockedPost < LockedPost
end

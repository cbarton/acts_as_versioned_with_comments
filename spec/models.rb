class Post < ActiveRecord::Base
	belongs_to :author
	has_many :authors, :through => :versions, :order => 'name'
	belongs_to :revisor, :class_name => 'Author'
	has_many :revisors, :through => :versions, :class_name => 'Author', :order => 'name'

	acts_as_versioned :if => :on_the_wall? do 
		def self.included(base)
			base.cattr_accessor :on_the_wall
			@@on_the_wall = true
			base.belongs_to :author
			base.belongs_to :revisor, :class_name => 'Author'
		end

		def on_the_wall?
			@@on_the_wall == true
		end
	end
end

class Author < ActiveRecord::Base
	has_many :posts	
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

# Widget -
# 	Describes a model that tests the sequence, dependencies
#	  capabilities of acts_as_versioned
class Widget < ActiveRecord::Base
	acts_as_versioned :sequence_name => 'widgets_seq', 
										:association_options => {
											:dependent => :nullify,
											:order => 'version desc'
										}
	non_versioned_columns << 'foo'

end

# Landmark
# 	Describes a model that tests the if_changed
class Landmark < ActiveRecord::Base
	acts_as_versioned :if_changed => [:name, :long, :lat]
end

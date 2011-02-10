ActiveRecord::Schema.define :version => 0 do
	create_table :posts, :force => true do |t|
			t.string :title
			t.boolean :public
	end

	create_table :locked_posts, :force => true do |t|
			t.string :title
			t.string :body
			t.string :type
	end
end




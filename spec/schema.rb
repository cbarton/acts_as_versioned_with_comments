ActiveRecord::Schema.define :version => 0 do
	create_table :posts, :force => true do |t|
			t.string :title, :limit => 255
			t.boolean :public
			t.text :body
			t.integer :author_id
			t.integer :revisor_id
			t.datetime :created_on
			t.datetime :updated_on
	end

	create_table :locked_posts, :force => true do |t|
			t.string :title, :limit => 255
			t.text :body
			t.string :type
	end

	create_table :widgets, :force => true do |t|
			t.string :name, :limit => 50
			t.string :foo
			t.datetime :updated_at
	end

	create_table :authors, :force => true do |t|
		t.string :name
	end

	create_table :landmarks, :force => true do |t|
		t.float :lat
		t.float :long
		t.string :name
		t.string :doesnt_trigger_version
	end
end




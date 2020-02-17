class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(name:, breed:, id: nil)
		@id = id
		@name = name
		@breed = breed
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT
			) 	
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			DROP TABLE dogs
		SQL

		DB[:conn].execute(sql)
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed)
			VALUES (?, ?)
		SQL
		DB[:conn].execute(sql, self.name, self.breed)

		@id = DB[:conn].execute("SELECT 
			last_insert_rowid() FROM dogs")[0][0]

		self
	end

	def self.create(hash_boi)
		dog = Dog.new(hash_boi)
		dog.save
		dog
	end

	def self.new_from_db(row)
		hash_boi = {
			id: row[0],
			name: row[1],
			breed: row[2]
		}

		Dog.new(hash_boi)
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE id = ?
		SQL

		db_dog = DB[:conn].execute(sql, id)
		self.new_from_db(db_dog.flatten)
	end

	def self.find_or_create_by(name:, breed:)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ? AND breed = ?
		SQL

		db_dog = DB[:conn].execute(sql, name, breed).first

		if db_dog
			self.find_by_id(db_dog[0])
		else
			self.create(name: name, breed: breed)
		end
	end

	def self.db_test(name:, breed:)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ? AND breed = ?
		SQL

		db_dog = DB[:conn].execute(sql, name, breed).first
		puts db_dog
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ?
		SQL

		db_dog = DB[:conn].execute(sql, name).first
		self.new_from_db(db_dog)
	end

	def update
		sql = <<-SQL
			UPDATE dogs 
			SET name = ?, breed = ?
			WHERE id = ? 
		SQL

		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end
end

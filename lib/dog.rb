
class Dog 
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:) 
        @id = id 
        @name = name 
        @breed = breed 
    end 

    def self.create_table 
        sql = <<-SQL 
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end 

    def self.drop_table 
        DB[:conn].execute("DROP TABLE dogs")
    end 

    def self.new_from_db(row)
        dog_row = Dog.new(id: row[0], name: row[1], breed: row[2])
        dog_row 
    end 

    def save 
        sql = <<-SQL 
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed) 
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        Dog.new(id: @id, name: self.name, breed: self.breed)
    end 
    
    def self.create(dog_attributes)
      # takes in a hash of attributes and uses metaprogramming to 
      # create a new dog object. Then it uses the #save method to save that
      new_dog = Dog.new(name: dog_attributes[:name], breed: dog_attributes[:breed])
      new_dog.save 
    end 

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
      dog_id = nil 
      DB[:conn].execute(sql, id).each do |dog_row|
        dog_id = self.new_from_db(dog_row)
      end 
      dog_id 
    end 
    
    def self.find_or_create_by(name: , breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty? 
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else 
        dog = Dog.create(name: name, breed: breed)
      end 
      dog 
    end 
    
    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ?"
      dog_name = nil
      DB[:conn].execute(sql, name).select do |dog_row|
        dog_name = self.new_from_db(dog_row)
      end 
      dog_name
    end 
    
    def update 
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
      #binding.pry 
    end 


end 













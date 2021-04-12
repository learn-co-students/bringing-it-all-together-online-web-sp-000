require_relative '../config/environment.rb'

class Dog
    
    attr_accessor :name, :breed, :id

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed        
    end
    
    def self.create_table
       sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
       SQL

       DB[:conn].execute(sql)        
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")        
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES(?, ?)
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        new_dog.save        
    end

    def self.new_from_db(row)
        new_dog = Dog.new(id:row[0], name:row[1], breed:row[2])  
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL

        dog = DB[:conn].execute(sql, id)
        Dog.new_from_db(dog[0])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE name = ? AND breed = ?
        SQL
        # binding.pry
        dog = DB[:conn].execute(sql, name, breed)
        # binding.pry
        if !dog.empty?
            Dog.new_from_db(dog[0])
        else
            dog = self.create(name:name, breed:breed)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name)
        Dog.new_from_db(dog[0])        
    end

    def update
        sql = <<-SQL
            UPDATE dogs 
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        
        dog = DB[:conn].execute(sql, self.name, self.breed, self.id)        
    end

end

# binding.pry
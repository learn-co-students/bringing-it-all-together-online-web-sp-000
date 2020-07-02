require 'pry'
class Dog
    attr_accessor :name, :breed, :id
    
    def initialize(id: nil, name:, breed:)
        @id = id 
        @name = name 
        @breed = breed
    end 

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER
                name TEXT
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
        if self.id 
            self.update
        else 
            sql = <<-SQL
                INSERT INTO dogs (name, breed) 
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end 
        self 
    end 

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end 

    def self.new_from_db(data_array)
        self.new(id: data_array[0], name: data_array[1], breed: data_array[2])
    end 

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.id = id 
        SQL
        DB[:conn].execute(sql).map{|row| self.new_from_db(row)}.first
    end 

    def self.find_or_create_by(name:, breed:)
        dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
        if !dog_array.empty?
            dog = self.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
        else 
            dog = self.create(name: name, breed: breed)
        end 
        dog 
    end 

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
    end 

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 
end 
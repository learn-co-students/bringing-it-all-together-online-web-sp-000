require 'pry'

class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
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
        sql = "DROP TABLE dogs"
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
            return self
        end
    end

    def self.create(inputHash)
        newDog = Dog.new(name: inputHash[:name], breed: inputHash[:breed])
        #binding.pry
        newDog.save
        return newDog
    end

    def self.new_from_db(row)
        newDog = Dog.new(name: row[1], breed: row[2], id: row[0])
        newDog.save
       # binding.pry
        return newDog
    end

    def self.find_by_name(inputName)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL
        dogDetails = DB[:conn].execute(sql, inputName)[0]
        newDog = Dog.new(id: dogDetails[0], name: dogDetails[1], breed: dogDetails[2])
        return newDog
    end

    def self.find_by_id(inputID)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, inputID)[0]
        newDog = Dog.new(id: row[0], name: row[1], breed: row[2])
       # binding.pry
        return newDog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(hash)
        foundDog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
        if !foundDog.empty?
            dogDetails = foundDog[0]
            newDog = Dog.new(id: dogDetails[0], name: dogDetails[1], breed: dogDetails[2])
            #binding.pry
            return newDog
        else
            newDog = Dog.new(name: hash[:name], breed: hash[:breed])
            newDog.save
            newDog
        end
    end
             



end
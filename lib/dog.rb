class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id = nil, hash)
        @id = id
        @name = hash[:name]
        @breed = hash[:breed] 
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
        sql = "DROP TABLE IF EXISTS dogs"
    
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        hash = {}
        hash[:name] =row[1]
        hash[:breed] = row[2]
        new_dog = self.new(row[0], hash)
        new_dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        hash = {}
        hash[:name] = result[1]
        hash[:breed] = result[2]
        self.new(result[0], hash)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        hash = {}
        hash[:name] = result[1]
        hash[:breed] = result[2]
        self.new(result[0], hash)
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            AND breed = ?
            SQL
        result = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
        if result 
            dog_id = Dog.find_by_name(hash[:name]).id
            Dog.find_by_id(dog_id)
        else
            Dog.create(hash)
        end
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
            Dog.find_by_id(self.id)
        end
    end

    def self.create(hash)
        new_dog = Dog.new(hash)
        new_dog.save
        new_dog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end

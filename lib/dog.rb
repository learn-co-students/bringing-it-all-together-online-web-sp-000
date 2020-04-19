class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
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
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def self.new_from_db(record)
        Dog.new(id: record[0], name: record[1], breed: record[2])
    end

    def self.create(id: nil, name:, breed:)
        dog = Dog.new(id: id, name: name, breed: breed)
        dog.save
        dog
    end

    def self.find_or_create_by(id: nil, name:, breed:)
        sql = "SELECT * FROM dogs WHERE name=? AND breed=?"
        results = DB[:conn].execute(sql, name, breed)
        if !results.empty?
            Dog.new_from_db(results[0])
        else
            Dog.create(name: name, breed: breed)
        end
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end
    
    def update
        sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name=?"        
        record = DB[:conn].execute(sql, name)[0]
        Dog.new_from_db(record)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id=?"
        record = DB[:conn].execute(sql, id)[0]
        Dog.new_from_db(record)
    end
end

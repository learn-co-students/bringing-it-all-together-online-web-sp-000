class Dog
    attr_accessor :id, :name, :breed

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
            );
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
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

    def update 
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
        self
    end 

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save 
        dog 
    end 

    def self.new_from_db(row) 
        dog = Dog.new(name: row[1], breed: row[2], id: row[0])
        dog 
    end 

    def self.find_by_id(id)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).flatten
        Dog.new(name: dog[1], breed: dog[2], id: id)
    end 

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
              SELECT *
              FROM dogs
              WHERE name = ?
              AND breed = ?
              LIMIT 1
            SQL
    
        dog = DB[:conn].execute(sql,name,breed)
    
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", name).flatten
        Dog.new(name: dog[1], breed: dog[2], id: dog[0])
    end 
end 
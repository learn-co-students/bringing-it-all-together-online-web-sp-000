class Dog

    attr_accessor :id, :name, :breed

    def initialize(dog_hash)
        @id = dog_hash[:id]
        @name = dog_hash[:name]
        @breed = dog_hash[:breed]
    end

    def self.create_table
        sql = "
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        "
    DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end


    def self.new_from_db(row) # looks at the DB row and assigns a new object
        
        dog_hash = {
            id: row[0],
            name: row[1],
            breed: row[2]
        }
        new_dog = self.new(dog_hash)
    
        new_dog
    end 
    
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * from dogs 
        WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map do |row| self.new_from_db(row)
        end.first
    end

    def self.find_by_id(id_search)
        sql = <<-SQL
        SELECT * from dogs 
        WHERE id= ?
        SQL
        DB[:conn].execute(sql, id_search).map do |row| self.new_from_db(row)
        end.first
    end




    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
        else
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end


    def self.create(dog_hash)
        new_dog = self.new(dog_hash)
        new_dog.save
        new_dog
    end


    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            puts dog[0]
            dog_hash = {
                id: dog[0][0],
                name: dog[0][1],
                breed: dog[0][2]
            }
            dog = Dog.new(dog_hash)
        else

            dog = Dog.create({name:name, breed: breed})
        end
    end

            
        











end #of class


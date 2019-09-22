class Dog

    attr_accessor :id, :name, :breed

    def initialize(dog_hash)
        @id = id
        @name = name
        @breed = breed
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
        new_dog = self.new(nil)
        new_dog.id = row[0]
        new_dog.name = row[1]
        new_dog.breed = row[2]
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





end #of class


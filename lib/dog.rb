class Dog
    attr_accessor :name,:breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name= name
        @breed= breed
        @id= id
    end

    def self.create_table
        sql_create_table = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL
        DB[:conn].execute(sql_create_table)
    end

    def self.drop_table
        sql_drop_table = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql_drop_table)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = Dog.new(name: row[1],breed: row[2], id: row[0])
        dog
    end

    def self.find_by_id(id)
        sql_find_by_id = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].execute(sql_find_by_id, id).map {|dog| self.new_from_db(dog)}.first
    end

    def self.find_or_create_by(name:,breed:)
        dog_search = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?',name,breed)
        if !dog_search.empty?
            found_dog = dog_search[0]
            dog = Dog.new(name: found_dog[1], breed: found_dog[2], id: found_dog[0])
        else
           dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql_find_by_name = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql_find_by_name,name).collect {|dog| self.new_from_db(dog)}.first
    end

    def save
        if self.id
            self.update
        else
        sql_save = <<-SQL
            INSERT INTO dogs(name,breed)
            VALUES (?,?)
        SQL
        DB[:conn].execute(sql_save,self.name,self.breed)
        @id = DB[:conn].execute('SELECT last_insert_rowid()')[0][0]
        end
        self
    end

    def update
        sql_update = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql_update,self.name,self.breed,self.id)
    end
    
end
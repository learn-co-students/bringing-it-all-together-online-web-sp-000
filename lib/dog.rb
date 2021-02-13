class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name: nil,  breed: nil)
        @id = id
        self.send("name=", name)
        self.send("breed=", breed)
    end

    def self.create_table
        sql =  <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
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
       Dog.new(id:row[0], name:row[1], breed:row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL

        result = DB[:conn].execute(sql, name)
        Dog.new_from_db(result[0])
    end

    def self.find_by_id(id_arg)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

        result = DB[:conn].execute(sql, id_arg)
        
        Dog.new_from_db(result[0])
    end

    def update
        sql = <<-SQL
        UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, name, breed, id)
    end

    def save
        if id != nil
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, name, breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        end
        self
    end

    def self.create(attr)
        dog = Dog.new(name: attr[:name], breed: attr[:breed])
 
        dog.save
        dog
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL

        result = DB[:conn].execute(sql, name, breed)
    
        if result == nil || result.count == 0
            create(name: name, breed: breed)
        else
            find_by_id(result[0][0])
        end
    end

end
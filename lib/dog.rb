class Dog
    attr_accessor :id, :name, :breed

    def initialize (id:nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name Text,
            breed Text
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

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id).first
        self.new_from_db(row)
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL

        row = DB[:conn].execute(sql, name).first
        self.new_from_db(row)

    end

    def self.find_or_create_by (name:, breed:)
        sql = <<-SQL 
        SELECT * FROM dogs
        Where name = ? AND breed = ?
        SQL

        row = DB[:conn].execute(sql, name, breed)

        if row.flatten == []
            hash = {name: name, breed: breed}
            dog = self.create(hash)
        else
            dog = Dog.new_from_db(row.flatten)
        end 
        dog  
        
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
        else
            self.insert
        end
        self
    end

    def self.create(hash)
        Dog.new(name: hash[:name], breed: hash[:breed]).tap do |dog|
            dog.id = hash[:id]
            dog.save
        end
    end

    def insert
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

end
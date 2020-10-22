class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
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

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(array)
        dog = Dog.new(id: array[0], name: array[1], breed: array[2])
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL

        array = DB[:conn].execute(sql, id)[0]

        self.new_from_db(array)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        AND breed = ?
        SQL

        dog = DB[:conn].execute(sql, name, breed)[0]

        if dog
            self.find_by_id(dog[0])
        else
            self.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL

        array = DB[:conn].execute(sql, name)[0]

        self.new_from_db(array)
    end
end
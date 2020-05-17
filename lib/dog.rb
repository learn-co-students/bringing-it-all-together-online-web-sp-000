class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name: name, breed: breed)
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
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
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
        end
        
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end 

    def self.new_from_db(row)
        # new_dog = Dog.new(id, name, breed)
        # new_dog.id = row[0]
        # new_dog.name = row[1]
        # new_dog.breed = row[2]
        # new_dog
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs 
        WHERE name = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL

        result = DB[:conn].execute(sql, id)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
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

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          select *
          from dogs
          where name = ? and breed = ?
        SQL
        row = DB[:conn].execute(sql, name, breed)[0]
        if row == nil
          self.create(name: name, breed: breed)
        else
          self.new_from_db(row)
        end
      end

end
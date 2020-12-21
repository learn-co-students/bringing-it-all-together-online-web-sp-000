class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: id = nil, name: name, breed: breed)
        @id = id
        @name = name
        @breed = breed
    end

    def save
        if self.id
            self.update
            self
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?,?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(hash)
        dog = self.new(name: hash[:name], breed: hash[:breed])
        dog.save
    end

    def self.new_from_db(row)
        dog = self.new(name: row[1], id: row[0], breed: row[2])
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * from dogs
            WHERE id = ?
        SQL

        dog_row = DB[:conn].execute(sql, id)[0]
        self.new_from_db(dog_row)
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        dog_row = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
        if dog_row
            self.new_from_db(dog_row)
        else
            self.create(hash)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        dog_row = DB[:conn].execute(sql, name)[0]
        self.new_from_db(dog_row)
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end
end
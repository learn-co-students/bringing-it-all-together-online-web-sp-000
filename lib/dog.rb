class Dog

    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
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

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, name, breed, id)
    end

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed).save
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL

        results = DB[:conn].execute(sql, id)
        dog = self.new_from_db(results[0])
    end

    def self.find_or_create_by(name:, breed:)
        results = DB[:conn].execute("SELECT * FROM dogs WHERE name= ? AND breed = ?", name, breed)

        if results.empty?
            self.create(name: name, breed: breed)
        else
            self.new_from_db(results[0])
        end
    end

    def self.find_by_name(name)
        results = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)

        if !results.empty?
            self.new_from_db(results[0])
        end
    end


end

class Dog
    attr_accessor :name, :breed
    attr_reader :id
    def initialize(name:, breed:, id:nil)
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
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES(?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attribs)
        Dog.new(attribs).save
    end

    def self.new_from_db(row)
        Dog.new(
            id: row[0],
            name: row[1],
            breed: row[2]
        )
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
        new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(attrs)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        result = DB[:conn].execute(sql, attrs[:name], attrs[:breed])
        if result.empty?
            new_dog = self.create(attrs)
        else
            new_from_db(result[0])
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL
        new_from_db(DB[:conn].execute(sql, name).first)
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
    end
end
class Dog
    attr_accessor :name, :breed, :id 

    def initialize(args)
        args.each { |key, value| self.send("#{key}=", value) }
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
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        # persist an instance of Dog to the database 
        # if it already exists, update the row with new information

        if self.id 
            self.update 
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

            self
        end
    end

    def self.create(args)
        dog = self.new(args)
        dog.save 
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id)[0]

        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]

        if row
            self.new_from_db(row)
        else
            args = {:name => name, :breed => breed}
            self.create(args)
        end
    end

    def self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]

        self.new_from_db(row)
    end

    def update 
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
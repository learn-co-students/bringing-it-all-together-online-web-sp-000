class Dog
    attr_accessor :name, :breed, :id

    # def initialize(h)
    #     h.each {|k,v| public_send("#{k}=",v)}
    # end
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
            grade TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
              INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL

            row = DB[:conn].execute(sql, self.name, self.breed)     
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        new_dog = self.new(name: row[1], breed: row[2], id: row[0])
        new_dog
    end

    def self.find_by_id(id)
        attrs = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).flatten

        Dog.new(id: attrs[0], name: attrs[1], breed: attrs[2])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

        if !dog.empty?
            dog_attr = dog[0]
            dog = Dog.new(id: dog_attr[0], name: dog_attr[1], breed: dog_attr[2])
        else
            dog = Dog.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        Dog.new_from_db(result)
        #Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
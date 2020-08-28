class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs(name, breed) VALUES(?, ?)", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end

    def self.create(attr)
        dog = Dog.new(name: attr[:name], breed: attr[:breed])
        dog.save
        dog
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = new_from_db(dog_data)
        else
            dog = self.create(name: name, breed:breed)
        end
        dog
    end

    def self.find_by_name(name)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        result.map do |row|
            self.new_from_db(row)
        end.first
    end
end
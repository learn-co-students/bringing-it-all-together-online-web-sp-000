require 'pry'
class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT);"

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs;"

        DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]

        self
    end

    def self.create(id: nil, name:, breed:)
        dog = Dog.new(id: id, name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]

        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = #{id};"

        table = DB[:conn].execute(sql)
        dog = Dog.new(id: table[0][0], name: table[0][1], breed: table[0][2])
    end

    def self.find_or_create_by(id: nil, name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_info = dog[0]
            dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = '#{name}';"

        dog_info = DB[:conn].execute(sql)
        self.new_from_db(dog_info[0])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
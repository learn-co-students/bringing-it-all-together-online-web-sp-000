require 'pry'

class Dog
    attr_accessor :name, :breed, :id

    def initialize(name: nil, breed: nil, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                breed TEXT
            );
            SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        dog = DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.new_from_db(row)
        dog = Dog.new
        dog.id = row[0]
        dog.name = row[1]
        dog.breed = row[2]
        dog
    end

    def self.find_by_id(id)
        DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1", id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.create(name:, breed:)
        dog =self.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end

      def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end







        

         

end
require "pry"

class Dog 
    attr_accessor :db, :name, :breed, :id 

    def initialize(db)
        @db = db 
        @name = db[:name]
        @breed = db[:breed]
        @id = nil 
    end 

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
                )"
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end 

    def save 
        sql = "INSERT INTO dogs (name, breed)
                VALUES (?, ?)"

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        Dog.new(DB)
    end

    def self.create(name:, breed:)
        ween = Dog.new(DB)
        ween.name = name 
        ween.breed = breed
        ween.save
        ween
    end 

    def self.new_from_db(row)
        @id = row[0]
        name = row[1]
        breed = row[2]

        ween = Dog.new(DB)
        ween.id = @id 
        ween.name = name 
        ween.breed = breed

        ween
    end 

    def self.find_by_id(x) 
        sql = "SELECT *
                FROM dogs
                WHERE id = ?"

        row = DB[:conn].execute(sql, x)
        var = Dog.new_from_db(row[0])
    end 

    def self.find_or_create_by(name:, breed:)
        dog_info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        row = dog_info[0]
            if row == nil 
                var = self.create(name: name, breed: breed)
            else
                var = self.new_from_db(row)
            end
    end
    
    def self.find_by_name(x)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", x)[0]
        self.new_from_db(row)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end

class Dog

    attr_accessor :id, :name, :breed

    def initialize(dog_hash)
        dog_hash.each do |key, val|
            self.send "#{key}=", val
        end
    end
    
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
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
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
       sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
       SQL
       DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.new_from_db(row)
        dog_hash = {:id => row[0], :name => row[1], :breed => row[2]}
        new_dog = self.new(dog_hash)
        new_dog  # return the newly created instance
    end

    def self.find_by_name(my_name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, my_name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_id(my_id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, my_id).map do |row|
           self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name:  dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.create(dog_hash)
        dog = self.new(dog_hash)
        dog.save
        dog
    end
end

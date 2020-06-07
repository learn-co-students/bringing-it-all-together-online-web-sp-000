class Dog
    attr_accessor :name, :breed, :id

    def initialize(attributes) #hash
        attributes.each do |key, value|
            self.send("#{key}=", value)
            self.id ||=nil
        end
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (
                name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self

    end

    def self.create(attributes) #hash
        dog = Dog.new(attributes)
        dog.save
        dog

    end

    def self.new_from_db(row) #row = [1, "Pat", "poodle"]
        new_from_array = {} #new hash
        new_from_array['id'] = row[0]
        new_from_array['name'] = row[1]
        new_from_array['breed'] = row[2]
        new_dog = self.new(new_from_array)
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",
        name, breed).first
        if dog #there is an existing dog
            dog_data = dog[0]
            dog = Dog.new_from_db(dog_data)
        else
            dog_data
            dog = self.create({:name => name, :breed => breed})
        end
        dog  
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    

end
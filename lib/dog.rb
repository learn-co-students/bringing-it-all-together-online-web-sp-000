class Dog
    attr_accessor :id, :name, :breed

    def initialize (id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
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
            DROP TABLE IF EXISTS dogs;
        SQL

        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        row_id = row[0]
        row_name = row[1]
        row_breed = row[2]
        new_dog = Dog.new(id: row_id, name: row_name, breed: row_breed)
        new_dog
    end

    def self.create(hash_atr)
        new_dog = Dog.new(id: nil, name: nil, breed: nil)
        hash_atr.each do |key, value|
            new_dog.send(("#{key}="), value)
        end
        new_dog.save
        new_dog
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def insert
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?);
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

    def save
        if (self.id != nil)
            self.update
            self
        else
            self.insert
            self
        end
    end

    def self.find_by_name(name_input)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? LIMIT 1;
        SQL

        found_row = DB[:conn].execute(sql, name_input)[0]
        self.new_from_db(found_row)
    end

    def self.find_by_id(id_input)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ? LIMIT 1;
        SQL

        found_row = DB[:conn].execute(sql, id_input)[0]
        self.new_from_db(found_row)
    end

    def self.find_or_create_by(hash_atr)
        name_input = hash_atr[:name]
        breed_input = hash_atr[:breed]
        if (self.find_by_name(name_input) != nil && self.find_by_name(name_input).breed == breed_input)
            self.find_by_name(name_input)
        else
            self.create(hash_atr)
        end
    end
   
end
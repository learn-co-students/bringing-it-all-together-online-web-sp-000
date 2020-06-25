class Dog
    attr_accessor :name, :breed, :id
    
    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
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
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        
        SQL
        DB[:conn].execute(sql)
    end
    def save
        if self.id != nil
            self.update

        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            #binding.pry
            self
        end

    end

    def self.create(attributes)
        newDog = Dog.new(attributes)
        newDog.save

    end
    def self.new_from_db(row)
        hashNew = {
            :id => row[0],
            :name => row[1],
            :breed => row[2]
        }
        newDog = Dog.new(hashNew)
        newDog
    end
    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        result = DB[:conn].execute(sql, id)[0]
        newDog = Dog.new_from_db(result)
        newDog
    end

    def self.find_or_create_by(attributes)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        results = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]
        #binding.pry
        if results == nil
            Dog.create(attributes)
        else
            Dog.new_from_db(results)
        end
    end
    
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL

        results = DB[:conn].execute(sql, name)[0]
        newDog = Dog.new_from_db(results)
        newDog
    end
    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
class Dog 
    attr_reader :id
    attr_accessor :name, :breed 

    def initialize(id: nil, name:, breed:)
        @name = name 
        @breed = breed
        @id = id
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
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql="INSERT INTO dogs(name, breed) VALUES (?,?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id ||= DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
        self
    end

    def self.create(attr={})
        new(name: attr[:name], breed: attr[:breed]).save
    end

    def self.new_from_db(row) 
        id= row[0]
        name = row[1]
        breed = row[2]
        new(id: id, name: name, breed: breed).save
    end

    def self.find_by_id(id)
        sql ="SELECT *
        FROM dogs
        WHERE id = ?"
        dog = DB[:conn].execute(sql, id).map{|row| new_from_db(row)}.first
        dog
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE (name = ? AND breed = ?)
        LIMIT 1
        SQL
        dog_from_db = DB[:conn].execute(sql, name, breed).map{|row| new_from_db(row)}.first

        if !dog_from_db
          dog = create({name: name, breed: breed})
          find_or_create_by(name: dog.name, breed: dog.breed)
        else
           dog_from_db
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE name = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql,name).map{|row| new_from_db(row)}.first
    end

    def update
        sql = <<-SQL 
        UPDATE dogs 
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
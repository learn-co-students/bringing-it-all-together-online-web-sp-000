class Dog 

    attr_accessor :name, :breed
    attr_reader :id
  
    def initialize(id=nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
    end

    def self.create_table
        sql =  <<-SQL 
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT
            )
            SQL
        DB[:conn].execute(sql) 
    end

    def self.drop_table 
        sql =  <<-SQL 
          DROP TABLE IF EXISTS dogs 
            SQL
        DB[:conn].execute(sql) 
    end

    def self.new_from_db(row)
        new_dog = self.new  # self.new is the same as running Song.new
        new_dog.id = row[0]
        new_dog.name =  row[1]
        new_dog.breed = row[2]
        new_dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        Song.new(result[0], result[1], result[2])
      end

    def self.find_or_create_by

    end

    def self.find_by_name

    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
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
    end

end
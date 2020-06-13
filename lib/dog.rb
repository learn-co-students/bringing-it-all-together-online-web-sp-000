require 'pry'
class Dog
    attr_accessor :name, :breed
    attr_reader :id
    
    def initialize(name:, breed:, id:nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
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
        @id = DB[:conn].execute("SELECT last_insert_rowid()
        FROM dogs")[0][0]
        self
        end
      end

      def self.create(name:, breed:)
        dog = self.new(name:name, breed:breed)
        dog.save
      end

      def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(name:name, breed:breed, id:id)
      end

      def self.find_by_id(num)
        sql = <<-SQL
        SELECT *
        from dogs
        WHERE dogs.id = ?
        SQL

        row = DB[:conn].execute(sql, num)
        id = row[0][0]
        name = row[0][1]
        breed = row[0][2]
        dog = self.new(name:name, breed:breed, id:id)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.name = ?
        SQL

        row = DB[:conn].execute(sql, name)
        if !row
         return   Dog.new(name:name, breed:breed)
        else
        a = row.select{|x| x.include?("#{breed}")}
        a.flatten!
        id = a[0]
        name = a[0]
        breed = a[0]
        dog = self.new(name:name, breed:breed, id:id)
        binding.pry
        return dog
        end
         
    end

end

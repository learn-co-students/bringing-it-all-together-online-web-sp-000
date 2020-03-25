

class Dog

    attr_accessor :name, :breed
    attr_reader :id
    @@all = []

    def initialize(id = nil, name, breed)
      @id = id
      @name = name
      @breed = breed
      @@all << self
    end

    def self.create_table
      sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL

        DB[:conn].execute(sql)  #execute SQL statement on database table
    end

    def self.drop_table
      sql= <<-SQL
      DROP TABLE dogs
      SQL
      DB[:conn].execute(sql) #execute SQL statement on database table
    end

    def self.new_from_db(row)
      # create a new dog object given a row from the database
           id = row[0]
           name = row[1]
           breed = row[2]
           self.new(id, name, breed)
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row) #creates a new instance without overwriting initialize
        end.first
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
      #this method really persists the student instance copy to the database
          if self.id
              self.update  #if there already exists an object instance (row in db) then just update it
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

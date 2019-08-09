class Dog

attr_accessor :name, :breed, :id
@@all = []
def initialize(id: nil, name:, breed:)
@id = id
@name = name
@breed = breed
@@all << self
# binding.pry
end

def self.all
  @@all
end


def self.create_table
  sql =<<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
  DB[:conn].execute(sql)
end

def self.drop_table
sql =<<-SQL
  DROP TABLE dogs
SQL
 DB[:conn].execute(sql)
end

def save
  sql =<<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?,?)
  SQL

  DB[:conn].execute(sql, self.name, self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end

def self.create(hash)
  dog = self.new(hash)
  dog.save
  dog
end

def self.new_from_db(db_row)
  dog = self.new(id: db_row[0], name: db_row[1], breed: db_row[2])
end

def self.find_by_id(id_number)
  sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
  SQL

  object_array = DB[:conn].execute(sql, id_number)
  found_dog = self.new(id: object_array[0][0], name: object_array[0][1], breed: object_array[0][2])
end

  def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL


        dog = DB[:conn].execute(sql, name, breed).first

        if dog
          new_dog = self.new_from_db(dog)
        else
          new_dog = self.create({:name => name, :breed => breed})
        end
        new_dog
    end

def self.find_by_name(input_name)
  sql =<<-SQL
    SELECT * FROM dogs
    WHERE name = ?
  SQL

  object_array = DB[:conn].execute(sql, input_name)
  new_from_db(object_array[0])
end

def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

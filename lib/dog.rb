class Dog 
  
  attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)
  @name = name
  @breed = breed
  @id = id
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
  
  
  def save 
  
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL
 
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
 self
  end
  
  
  def Dog.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end
  
  
   def self.new_from_db(row)
    dog_hash = {:name => row[1], :id => row[0], :breed => row[2]}
    new_dog = Dog.new(dog_hash)
    new_dog
  end
  
   def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.id
    @id
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?  
          AND breed = ?
          LIMIT 1
        SQL

    dog_returned = DB[:conn].execute(sql,name,breed)

    if dog_returned.empty? == false
      dog_item = dog_returned[0]
      dog_final = Dog.new(id: dog_item[0], name: dog_item[1], breed: dog_item[2])
    else
      dog_final = self.create(name: name, breed: breed)
    end
    dog_final
  end
  
  def update
    sql = <<-SQL 
    UPDATE dogs SET name = ?, breed = ?  WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
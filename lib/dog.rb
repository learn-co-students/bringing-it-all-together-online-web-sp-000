require 'pry'

class Dog 
  
  attr_accessor :name, :breed, :id

  
  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end
  
  def self.create_table 
    
    sql = <<-SQL 
    CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT, 
    breed TEXT
    )
    SQL
    
    DB[:conn].execute(sql)
    
  end
  
  def self.drop_table
    
    sql = <<-SQL 
    DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql)
    
  end
  
  def self.new_from_db(row) 
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(name)
    
    sql = <<-SQL 
    SELECT * 
    FROM dogs 
    WHERE name = ?
    SQL
    
    
    DB[:conn].execute(sql, name)
    
  end
  
  def save 
    
    sql = <<-SQL 
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    
    new_dog = DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
    
  end
  
  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end
  
  def self.find_by_id(id)
    
    sql = <<-SQL 
    SELECT * 
    FROM dogs 
    WHERE id = ?
    SQL
    
    row = DB[:conn].execute(sql, id)
    self.new_from_db(row[0])
    
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      new_dog = Dog.new({"id": dog_data[0], name: dog_data[1], breed: dog_data[2]})
    else
      new_dog = self.create(name: name, breed: breed)
    end
      new_dog
  end
  
  def self.find_by_name(name)
    
    sql = <<-SQL 
    SELECT * 
    FROM dogs 
    WHERE name = ?
    SQL
    
    row = DB[:conn].execute(sql, name)
    
    self.new_from_db(row[0])
    
  end
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  
end
class Dog 
  attr_accessor :id, :name, :breed
  
  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed 
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)
    SQL
    
    DB[:conn].execute(sql)
    
  end
  
  def self.drop_table 
    
    sql = <<-SQL 
    DROP TABLE IF EXISTS dogs
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(row)
    dog = Dog.new(name:row[1], breed:row[2], id:row[0])
    dog
  end 
  
  def self.find_by_name(name)
    
    sql = <<-SQL 
    SELECT * FROM dogs 
    WHERE name = ?
    SQL
    
    new_from_db(DB[:conn].execute(sql, name)[0])
    
  end
  
  def self.find_by_id(id)
    
    sql = <<-SQL 
    SELECT * FROM dogs 
    WHERE id = ? 
    SQL
    
    new_from_db(DB[:conn].execute(sql, id)[0])
    
  end
  
  def self.find_or_create_by(name:, breed:)
    
    sql = <<-SQL
    SELECT * FROM dogs 
    WHERE name = ? AND breed = ?
    SQL
    
    
    dog = (DB[:conn].execute(sql, name, breed)[0])
    
    if dog
      dog_data = dog[0]
      dog = Dog.new(name:dog_data[1], breed:dog_data[2], id:dog_data[0])
    else 
      dog_data = {name: name, breed: breed}
      dog = create(dog_data)
    end
  end
  
  def save 
    
    sql = <<-SQL 
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed) 
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  
    end
  
  def self.create(dog_hash)
    dog = Dog.new(name:dog_hash[:name], breed:dog_hash[:breed], id:nil)
    dog.save 
    dog
  end 
  
  def update 
    sql = <<-SQL 
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    
  end
  
end 
class Dog 
  attr_accessor :id, :name, :breed 
  
  def initialize(name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = 
  end
  
  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    
  end
  
  def self.create(attribute_hash)
    dog = Dog.new(attribute_hash)
    dog.save
    dog
    
  end
  
  def self.new_from_db
    
  end
  
  def self.find_by_id
    
  end
  
  def self.find_or_create_by
    
  end
  
  def self.find_by_name
    
  end
  
  def update
    
  end
  
end





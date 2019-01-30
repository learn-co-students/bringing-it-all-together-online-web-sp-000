require 'pry'

class Dog 
  attr_accessor :id, :name, :breed 
  
  def initialize(id: nil, name:, breed:)
    @id=id
    @name=name
    @breed=breed
  end 
  
  def self.create_table 
    sql=<<-SQL 
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
      SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table 
     DB[:conn].execute("DROP TABLE dogs")
  end
  
  def save
    if self.id
      self.update
    else
     sql=<<-SQL 
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
    end
  end
  
  def self.create(attribute_hash)
    dog=Dog.new(name: attribute_hash[:name], breed: attribute_hash[:breed])
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql=<<-SQL
      SELECT * FROM dogs 
      WHERE ID = ? 
    SQL
    
    dog_array = DB[:conn].execute(sql, id)[0]
    self.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
  end
  
  def self.find_by_name(name)
     sql=<<-SQL
      SELECT * FROM dogs 
      WHERE name = ? 
    SQL
    
    dog_array = DB[:conn].execute(sql, name)[0]
    self.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
  end
  
  def update 
    sql=<<-SQL
    UPDATE dogs
    SET name = ?, breed = ? 
    WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
 
  def self.find_or_create_by(attribute_hash)
    sql=<<-SQL 
      SELECT * FROM dogs 
      WHERE name = ? 
      AND breed = ?
    SQL
    
    dog = DB[:conn].execute(sql, attribute_hash[:name], attribute_hash[:breed])[0]
    
    if dog == nil
      self.create(attribute_hash)
    else 
      self.new_from_db(dog)
    end
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
    
    

end
    
class Dog 

  attr_accessor :id, :name, :breed
  
  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
    self.id ||= nil
  end 
  
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)"
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end
  
  def save 
    sql = "INSERT INTO dogs (name, breed) VALUES ( ?, ? )"
    DB[:conn].execute(sql, self.name, self.breed)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end 
  
  def self.new_from_db(array)
    attributes_hash = {
      :id => array[0],
      :name => array[1],
      :breed => array[2]
    }
    self.new(attributes_hash) 
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    
    dog = DB[:conn].execute(sql, name, breed).first
    
    if dog 
      new_dog = self.new_from_db(dog)
    else !dog
      new_dog = self.create({:name => name, :breed => breed})
    end 
    new_dog
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
end
  
end

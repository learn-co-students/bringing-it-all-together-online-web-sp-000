class Dog
  
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    table  = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
      SQL
    
    DB[:conn].execute(table)
  end
  
  def self.drop_table
    drop = <<-SQL
        DROP TABLE dogs
      SQL
      
    DB[:conn].execute(drop)
  end
  
  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES ( ?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.create(name:, breed:)
    dog_oi = self.new(name: name, breed: breed)
    dog_oi.save
    dog_oi
  end
    
  def self.new_from_db(array)
    self.new(id: array[0], name: array[1], breed: array[2])
  end
  
  def self.find_by_id(id)
    find = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
      
    array = DB[:conn].execute(find, id).flatten
    dog_oi = self.new(id: array[0], name: array[1], breed: array[2])
    dog_oi 
  end
  
  def self.find_or_create_by(name:, breed:)
    find = <<-SQL
        SELECT * FROM dogs 
        WHERE name = ? AND breed = ?
        LIMIT 1
      SQL
    array = DB[:conn].execute(find, name, breed).first
    if array
      dog_oi = self.new(id: array[0], name: array[1], breed: array[2])
      dog_oi
    else
      self.create(name: name, breed: breed)
    end
  end
  
  def self.find_by_name(name)
    find = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        LIMIT 1
      SQL
    
    array = DB[:conn].execute(find, name).first
    dog_oi = self.new(id: array[0], name: array[1], breed: array[2])
    dog_oi
  end
    
  def update
    update = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
      SQL
    DB[:conn].execute(update, self.name, self.breed, self.id)
  end
  
end
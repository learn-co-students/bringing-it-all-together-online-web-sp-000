class Dog 
  
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    dog = <<-SQL
    CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)
    SQL
    
    DB[:conn].execute(dog)
  end
  
  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end
  
  def save
    if self.id
      self.update
    else
      dog = <<-SQL 
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL
      
      DB[:conn].execute(dog, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
  
  def self.create(attributes)
    doggo = new(attributes)
    doggo.save
    doggo
  end
  
  def self.new_from_db(pupper)
    doggo = new(id: pupper[0], name: pupper[1], breed: pupper[2])
    doggo
  end
  
  def self.find_by_id(id)
    doggo = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', id)[0]
    new_from_db(doggo)
    
  end
  
  def self.find_or_create_by(name:, breed:)
    doggo = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed)
    
    if doggo.empty?
      create(name: name, breed: breed)
    else 
      dog = doggo[0]
      self.new(id: dog[0] ,name: dog[0] ,breed: dog[0] )
    end
      
  end
  
  def self.find_by_name(name)
    # binding.pry
    doggo = DB[:conn].execute('SELECT * FROM dogs WHERE name = ?', name)[0]
    self.new(id: doggo[0], name: doggo[1], breed: [2])
  end
  
  def update
    DB[:conn].execute('UPDATE dogs SET id = ?, name = ? , breed = ?', self.id, self.name, self.breed)
  end
  
end 
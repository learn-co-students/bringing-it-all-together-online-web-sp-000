class Dog 
  
  attr_accessor :name, :breed, :id
  
  def initialize(id: nil, breed:, name:)
    @id=id 
    @breed=breed 
    @name=name
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
      DROP TABLE dogs
        SQL
    DB[:conn].execute(sql) 
  end
  
  def save
    if self.id 
      self.update 
    else   
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]  
    end
    self
  end
  
  def self.create(args)
    dog = Dog.new(args)
    dog.save
    dog
  end
  
  def self.new_from_db(args)
    id = args[0]
    name =  args[1]
    breed = args[2]
    self.new(id: id, name: name, breed: breed) 
  end  
  
   def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end
  
  def self.find_or_create_by(breed:, name:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE breed = ? AND name = ?", breed, name)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(breed: breed, name: name)
    end
    dog
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end
  
  def update
     sql = "UPDATE dogs SET breed = ?, name = ? WHERE id = ?"
    DB[:conn].execute(sql, self.breed, self.name, self.id)
  end
  
end
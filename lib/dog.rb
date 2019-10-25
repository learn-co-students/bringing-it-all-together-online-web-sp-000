class Dog
  
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.::create_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
    Dog.create_table
  end
  
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end
  
  def self.::drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def self.::new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    Dog.new(id: id, name: name, breed: breed)
  end
  
  def self.::find_by_name(name)
    sql = "SELECT*FROM dogs WHERE name = ?"
    dog_data = DB[:conn].execute(sql, name)[0]
    Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end  
  
  def update
	  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
	  DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def save
	  if self.id
		  self.update
	  else
		  sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
		  DB[:conn].execute(sql, self.name, self.breed)
		  self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
	  end
  end
  
end
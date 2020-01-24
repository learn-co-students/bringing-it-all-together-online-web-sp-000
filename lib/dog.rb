class Dog 
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, breed:, id: nil)
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
    DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", self.name, self.breed)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end 
  
  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end 
  
  def self.new_from_db(row)
    new_dog = self.new(name: row[1],breed: row[2],id: row[0])
  end 
  
  def self.find_by_id(id_num)
    sql = <<-SQL
      SELECT * FROM dogs 
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, id_num).map {|column_row| self.new_from_db(column_row)}.first
  end 
  
  def self.find_or_create_by(name:, breed:)
    dog_search = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog_search.empty?
      dog_found = dog_search[0]
      dog_search = self.new(id: dog_found[0], name: dog_found[1], breed: dog_found[2])
    else 
      dog_search = self.create(name: name, breed: breed)
    end 
    dog_search
  end 
  
  def self.find_by_name(dog_name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", dog_name).map{|column_row| self.new_from_db(column_row)}.first
  end 
  
  def update 
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
end 
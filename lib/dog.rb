require 'pry'

class Dog 
  attr_accessor :name, :breed, :id 
  
  def initialize(name:, breed:, id: nil)
    @name = name 
    @breed = breed 
    @id = id 
  end 
  
  def self.create_table 
    sql = %{
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY, 
        name TEXT,
        breed TEXT 
        )
    }
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end 
  
  def save 
    sql = %{
      INSERT INTO dogs (name, breed) VALUES 
      (?, ?)
    }
    DB[:conn].execute(sql,name,breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self 
  end 
  
  def self.create(name:, breed:)
    doggo = Dog.new(name: name, breed: breed)
    doggo.save
    doggo
  end 
  
  def self.find_by_id(id_num) 
    sql = %{
      SELECT * FROM dogs 
      WHERE id = ?
    }
    row = DB[:conn].execute(sql, id_num)[0]
    doggo = Dog.new(id: row[0], name: row[1], breed: row[2])
  end 
  
  def self.find_or_create_by(name:, breed:)
    sql = %{
      SELECT * FROM dogs 
      WHERE name = ? AND breed = ?
      LIMIT 1 
    }
    
    row = DB[:conn].execute(sql, name, breed)
    if !row.empty?
      Dog.new(id: row[0][0], name: row[0][1], breed: row[0][2])
    else 
      Dog.create(name: name, breed: breed)
    end
  end 
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    Dog.new(id: id, name: name, breed: breed)
  end 
  
  def self.find_by_name(the_name)
    sql = %{
      SELECT * FROM dogs 
      WHERE name = ?
    }
    row = DB[:conn].execute(sql,the_name)[0]
    self.new_from_db(row)
  end 
  
  def update
    sql = %{
      UPDATE dogs 
      SET name = ?, breed = ? WHERE id = ?
    }
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
end 
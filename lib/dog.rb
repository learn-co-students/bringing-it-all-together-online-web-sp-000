require 'pry'

class Dog 
  
  attr_accessor :name, :breed, :id 
   
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end 
  
  def self.create_table 
    sql = "CREATE TABLE IF NOT EXISTS dogs( id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end 
  
  def save
    if self.id 
      self.update 
    else 
    sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id= DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end 
    self 
  end 
  
  def self.create(name:, breed:) 
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end 
  
  def self.find_by_id(id) 
    sql = "SELECT * FROM dogs WHERE id = ?"
    find = DB[:conn].execute(sql,id).flatten
    #binding.pry 
    self.new_from_db(find)
  end 
  
  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"

    find = DB[:conn].execute(sql,name,breed).flatten

    if !find.empty?
      dog = Dog.new(id: find[0], name: find[1], breed: find[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2]) 
  end 
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    dog = DB[:conn].execute(sql, name)
    dog = dog.flatten
    self.new_from_db(dog)
  end 
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql,self.name, self.breed, self.id)
  end 
  
end 
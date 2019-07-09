require 'pry'

class Dog 
  
  attr_accessor :name, :breed, :id 
   
  def initialize(name:, breed:, id: nil)
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
    sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
    DB[:conn].execute(sql, self.name, self.breed)
    self 
  end 
  
  def self.create(hash) 
    hash = Dog.new(name: hash[:name] , breed: hash[:breed])
    hash.save
  end 
  
  def self.find_by_id(id) 
    sql = "SELECT * FROM dogs WHERE id = ?"
    find = DB[:conn].execute(sql,id).flatten
    dog = Dog.new(id: find[0], name: find[1], breed: find[2])
  end 
  
  def self.find_or_create_by(name: , breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    find = DB[:conn].execute(sql,name,breed).flatten
    if !find.empty?
      #binding.pry 
      dog = Dog.new(id: find[0], name: find[1], breed: find[2])
    else 
      dog = self.create(name: name, id: id, breed: breed)
    end 
    dog 
  end 
  
end 
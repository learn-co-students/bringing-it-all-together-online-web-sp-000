class Dog 
  
  attr_accessor :name, :breed, :id

  @@all = []
  
  def initialize(params)
    @name = params[:name]
    @breed = params[:breed]
    @@all << self
  end
  
  def self.all 
    @@all.dup.freeze  
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
    sql = "DROP TABLE IF EXISTS dogs" 
    DB[:conn].execute(sql)
  end 
  
  def save
    insert_sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    select_sql = "SELECT id FROM dogs WHERE name = ? AND breed = ?"
    @id = DB[:conn].execute(insert_sql, self.name, self.breed)[0]
    @id = DB[:conn].execute(select_sql, self.name, self.breed)[0][0]
    self
  end 
  
  def self.create(params)
    self.new(params).save
  end 
  
  def self.new_from_db(row) 
  #binding.pry
    params = {:name => row[1], :breed => row[2]}
    new_dog = self.new(params)
    new_dog.id = row[0]
    new_dog
  end 
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end 
  
  def self.find_or_create_by(name:, breed:)
    #binding.pry 
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    row = DB[:conn].execute(sql, name, breed)[0]
    params = {:name => name, :breed => breed}
    row == nil ? self.create(params) : self.find_by_id(row[0])
  end 
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end 
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)[0]
  end 
  
end 
class Dog 
  attr_accessor :name, :breed, :id 
  
  def initialize(name:, breed:, id: nil)
    @name = name 
    @breed = breed 
    @id = id 
  end 
  
  def self.create_table 
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 
  
  def save 
    if self.id 
      self.update 
    else 
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)" 
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end 
  end 
  
  def self.create(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    new_student = self.new(@name, @breed)
    new_student.save 
  end 
  
  def self.find_by_id (id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map do |row| self.new_from_db(row) 
    end.first 
  end 

  def self.find_or_create_by 
  end 
  
  def self.find_by_name(name)
    
     sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map do |row| self.new_from_db(row) 
    end.first
  end 
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end 
  
 
    
    
    
  
  
  
end 
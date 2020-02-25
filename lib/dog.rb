class Dog 
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(id=nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end 
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    );
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(arr)
    arr.each do |dog|
      Dog.new(dog)
    end 
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? 
    SQL
    result = DB[:conn].execute(sql, name).flatten 
    new_dog = Dog.new(result)
    new_dog 
  end 
  
  def update
    
  end 
  
  def save 
  end 
end 
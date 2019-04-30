class Dog
  attr_accessor :name, :breed, :id
  
  def initialize(id:nil,name:,breed:)
    @name=name
    @breed=breed
    @id=id
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end
  
  def save
    sql=<<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
    self
  end
  
  def self.create(hash)
    dog=self.new(hash)
    dog.save
  end
  
  def self.find_by_id(id)
    sql=<<-SQL
      SELECT * FROM dogs WHERE id=?
    SQL
    dog=DB[:conn].execute(sql,id).flatten
    new_dog=self.new(id:dog[0],name:dog[1],breed:dog[2])
  end
  
  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? ", hash[name],hash[breed] )
    if !dog.empty?
      new_dog=Dog.new(id:dog[0][0],name:dog[0][1],breed:dog[0][2])
    else
      self.create(hash)
    end
  end 
  
end
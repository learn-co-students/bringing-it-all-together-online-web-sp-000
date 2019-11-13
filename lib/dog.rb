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
  
end
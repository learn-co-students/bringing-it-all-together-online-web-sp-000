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
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(hash)
    dog=self.new(hash)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql=<<-SQL
      SELECT * FROM dogs WHERE id=?
    SQL
    dog=DB[:conn].execute(sql,id).flatten
    new_dog=self.new(id:dog[0],name:dog[1],breed:dog[2])
  end
  def self.new_from_db(row)
    dog=Dog.new({id:row[0],name:row[1],breed:row[2]})
  end
  
  def self.find_or_create_by(name:,breed:)
    sql=<<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name,breed ).first
    if dog
      self.new_from_db(dog)
    else
      self.create({name:name,breed:breed})
    end
  end 
  
  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    result=DB[:conn].execute(sql, name)[0]
    Dog.new({id:result[0],name:result[1],breed:result[2]})
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
class Dog
  
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each { |key, value| self.send(("#{key}="), value)}
  end
  
  def self.dbc(*execute_this) #database connection
    DB[:conn].execute(*execute_this)
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs 
      (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    
    dbc(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    
    dbc(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
      
    Dog.dbc(sql, self.name, self.breed)
    @id = Dog.dbc("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end
  
  def self.new_from_db(row)
    dog=Dog.new({id:row[0],name:row[1],breed:row[2]})
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dbc(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:,breed:)
    sql=<<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    
    dog = dbc(sql, name, breed).first
    
    if dog
      self.new_from_db(dog)
    else
      self.create({name: name, breed: breed})
    end
  
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    dbc(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    Dog.dbc(sql, self.name, self.breed, self.id)
  end

  
  
end #end of Class Dog
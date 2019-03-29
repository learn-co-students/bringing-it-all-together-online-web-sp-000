
class Dog
  attr_accessor :id,:name, :breed
  
  def initialize(attrs)
    @name = attrs[:name]
    @breed = attrs[:breed]
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT, 
    breed TEXT);
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
  
  def save
    if self.id
      self.update
    else
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
    end
  end
  
  def self.create(attrs)
    dog = self.new(attrs)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * 
    FROM dogs
    WHERE dogs.id = ?
    SQL
    
    a = DB[:conn].execute(sql, id).flatten
    attrs = {:name => a[1], :breed => a[2]}
    dog = self.new(attrs)
    dog.id = a[0]
    dog
  end
  
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    dog_attrs = DB[:conn].execute(sql, name)[0]
    dog = self.new(:name => dog_attrs[1], :breed => dog_attrs[2])
    dog.id = dog_attrs[0]
    dog
  end
  
  
  def self.find_or_create_by(name:, breed:)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
      if !dog_data.empty?
       dog = self.new_from_db(dog_data)
      else
       dog = self.create(:name => name, :breed => breed)
      end
    dog
  end
  
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  
  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2])
    dog.id = row[0]
    dog
  end
  
  
  
end
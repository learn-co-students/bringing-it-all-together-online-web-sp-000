require "pry"
class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end
  
  def self.new_from_db(row)
    Dog.new(name:row[1],breed:row[2],id:row[0])
  end
  
  def self.create(name:, breed:)
    dog = Dog.new(name:name, breed:breed)
    dog.save
    dog
  end
  
  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs( name, breed ) VALUES (?,?);"
      DB[:conn].execute(sql, self.name, self.breed)
    end
    self
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name == ? LIMIT 1;"
    row = DB[:conn].execute(sql, name).first
    Dog.new_from_db(row)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id == ? LIMIT 1;"
    row = DB[:conn].execute(sql, id).first
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name == ? AND breed == ?", name, breed)
    binding.pry
    unless dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
   end


  def update
    sql = "UPDATE dogs SET name == ?, breed == ?  WHERE id == ?"
    DB[:conn].execute(sql, @name, @breed, @id)
    self
  end
end
require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
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

  def self.new_from_db(row)
    row_hash = {:id => row[0], :name => row[1], :breed => row[2]}
    Dog.new(row_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name).flatten
    result_hash = {:id => result[0], :name => result[1], :breed => result[2]}
    new_dog = Dog.new(result_hash)
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id).flatten
    result_hash = {:id => result[0], :name => result[1], :breed => result[2]}
    new_dog = Dog.new(result_hash)
    new_dog
  end

  def self.create(attr_hash)
    new_dog = Dog.new(attr_hash)
    new_dog.save
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.find_or_create_by(attr_hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr_hash[:name], attr_hash[:breed]).flatten
    dog_hash = {:id => dog[0], :name => dog[1], :breed => dog[2]}
    if !dog.empty?
      new_dog = Dog.new(dog_hash)
      new_dog
    else
      new_dog = Dog.create(dog_hash)
      new_dog
    end
  end
end

require 'pry'
class Dog
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:)
    @name = name
    @breed = breed
    @id = nil
  end
  
  def initialize(attributes)
    attributes.each { |key, val| self.send("#{key}=", val) }
  end
  
  def self.new_from_db(row)
    Dog.new({"id" => row[0], "name" => row[1], "breed" => row[2]})
  end
  
  def save
    if self.id
    else
      query = <<-SQL
        INSERT INTO dogs
          (name, breed) VALUES (?, ?);
        SQL
      DB[:conn].execute(query, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
  
  def update
    query = <<-SQL
      UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?;
      SQL
    DB[:conn].execute(query, @name, @breed, @id)
  end
  
  def self.find_by_id(id)
    query = <<-SQL
      select * from dogs
        where id = ?;
      SQL
    DB[:conn].execute(query, id).map do |row|
      Dog.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name: name, breed: breed)
    dog = DB[:conn].execute("select * from dogs where name = ? and breed = ?", name, breed)
    if !dog.empty?
      dog = Dog.new_from_db(dog[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def self.find_by_name(name)
    query = <<-SQL
      select * from dogs
        where name = ?;
      SQL
    DB[:conn].execute(query, name).map do |row|
      Dog.new_from_db(row)
    end.first
  end
  
  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end
  
  def self.create_table
    query = <<-SQL
      CREATE TABLE dogs
        (id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );
      SQL
    DB[:conn].execute(query)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end
end
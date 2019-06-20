require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(name: nil, breed: nil, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    # Dog #save saves an instance of the dog class to the database and then sets the given dogs `id` attribute

      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"

      DB[:conn].execute(sql, self.name, self.breed)

      row = DB[:conn].execute("SELECT * FROM dogs WHERE id = (SELECT MAX(id) FROM dogs)")[0]

      self.id = row[0]
      self
  end

  def self.create(attributes)
    dog = Dog.new
    attributes.each {|key, value| dog.send(("#{key}="), value)}
    dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id)[0]
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(attributes)

    sql = <<-SQL
    SELECT id FROM dogs
    WHERE EXISTS (SELECT id FROM dogs WHERE name = ? AND breed = ?)
    SQL

    value = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

    if value == []
      self.create(attributes)
    else
      self.find_by_id(value[0][0])
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"

    row = DB[:conn].execute(sql, name)[0]

    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

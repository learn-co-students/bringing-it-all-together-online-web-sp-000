require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name: names, breed: breeds, id: nil)
    @id = id
    @name = name
    @breed = breed
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
      SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
      SQL

    result = DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }
    result.first
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?);
      SQL

    DB[:conn].execute(sql, @name, @breed)
    self
  end

  def self.create(name: name, breed: breed)
    new_dog = self.new({ name: name, breed: breed, id: nil })
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
      SQL

    result = DB[:conn].execute(sql, id).map { |row| self.new_from_db(row) }
    result.first
  end

  def self.find_or_create_by(name: name, breed: breed)
    dog =
      DB[:conn].execute(
        'SELECT * FROM dogs WHERE name = ? AND breed = ?',
        name,
        breed,
      )
    binding.pry

    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end

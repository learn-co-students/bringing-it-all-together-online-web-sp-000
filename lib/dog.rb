require 'pry'
require_relative "../config/environment.rb"

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize (id: nil , name:, breed:)
    @id = id
    @name = name
    @breed = breed
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
    sql = <<-SQL
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
        VALUES(?,?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(db)
    id = db[0]
    name = db[1]
    breed = db[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
      SQL
    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    #binding.pry
    if self.find_by_name_and_breed(name, breed) != nil
      ret_val = self.find_by_name_and_breed(name, breed)
    else
      ret_val = self.create(name: name, breed: breed)
    end
  end

#additional custom method to find name and breed
  def self.find_by_name_and_breed(name, breed)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE (name = ? AND breed = ?)
      LIMIT 1
      SQL
    DB[:conn].execute(sql, name, breed).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      SQL
    ret_val = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?"
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

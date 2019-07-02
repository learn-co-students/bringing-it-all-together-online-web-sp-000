require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id = nil, attribute_hash)
    self.id = id
    attribute_hash.each do |attr, value|
      self.send("#{attr}=",value)
    end
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
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?);
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql,id)[0]
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?;
    SQL

    searched_dog = DB[:conn].execute(sql, hash[:name], hash[:breed])

    if !searched_dog.empty?
      Dog.new_from_db(searched_dog[0])
    else
      Dog.create(hash)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql,name)[0]
    Dog.new_from_db(row)
  end
end

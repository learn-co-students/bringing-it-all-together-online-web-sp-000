require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(params)
    @id = params[:id]
    @name = params[:name]
    @breed = params[:breed]
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
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(params)
    new_Dog = Dog.new(params)
    new_Dog.save
  end

  def self.new_from_db(row)
    params = {id: row[0], name: row[1], breed: row[2]}
    new_Dog = Dog.new(params)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    Dog.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(params)
    if params[:id]
      dog = Dog.find_by_id(params[:id])
    else
      dog = Dog.create(params)
    end
    dog
  end
end

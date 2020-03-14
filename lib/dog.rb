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
    #search db for params name + breed. should find id.
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    doggo_id = DB[:conn].execute(sql, params[:name], params[:breed])
    #if id, generate Dog, no need to create
    if doggo_id != []
      doggo_id = doggo_id[0][0]
      found_dog = Dog.find_by_id(doggo_id)
    #if not id, create dog
    else
      found_dog = Dog.create(params)
    end
    found_dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    Dog.new_from_db(DB[:conn].execute(sql, name)[0])
  end
end

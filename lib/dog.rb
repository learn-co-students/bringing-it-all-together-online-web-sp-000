class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id] ? hash[:id]: nil 
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save

  end

  def self.new_from_db(row)
    hash = {id: row[0], name: row[1], breed: row[2]}
    dog = self.new(hash)
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    new_from_db(row)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE name = ? AND breed =?
    SQL
    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    dog_data = dog[0]
    if !dog.empty?
      Dog.new_from_db(dog_data)
    else
      Dog.create(hash)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    new_from_db(row)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE ID = ?
    SQL
    DB[:conn].execute(sql, self.name, self.id)
  end
end
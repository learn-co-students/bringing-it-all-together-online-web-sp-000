class Dog
  attr_accessor :name, :breed, :id
  @@all = []

  def initialize(attr_hash)
    attr_hash.each {|k, v| self.send(("#{k}="), v)}
    @@all << self
  end

  def self.all
    @@all
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
    DB[:conn].execute("DROP TABLE dogs;")
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

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      self
    end
  end

  def self.create(attr_hash)
    dog = Dog.new(attr_hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten

    hash = {id: row[0], name: row[1], breed: row[2]}

    Dog.new(hash)
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", hash[:name], hash[:breed])

    if dog.empty?
      self.create(hash)
    else
      dog_data = dog[0]
      self.all.find {|d| d.id == dog_data[0]}
    end
  end

  def self.new_from_db(row)
    hash = {id: row[0], name: row[1], breed: row[2]}
    Dog.new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    dog_data = DB[:conn].execute(sql, name)[0]
    new_from_db(dog_data)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

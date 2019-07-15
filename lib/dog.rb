class Dog

  attr_accessor :id, :name, :breed

  def initialize(name: nil, breed: nil, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT);
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

    DB[:conn].execute(sql, self.name, self.breed)

    row = DB[:conn].execute("select last_insert_rowid() from dogs")[0]
    self.id = row[0]
    self
  end

  def self.create(dog_attributes)
    dog = Dog.new
    dog_attributes.each {|key, value| dog.send(("#{key}="), value)}
    dog.save
    dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("select * from dogs where id = ?", id)[0]
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "select * from dogs where name = ? AND breed = ?"
    row = DB[:conn].execute(sql, name, breed)
    if !row.empty?
      dog_data = row[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = Dog.new(name: name, breed: breed)
      dog.save
    end
    dog
  end

  def self.find_by_name(name)
    sql = "select * from dogs where name = ?"
    row = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(row)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

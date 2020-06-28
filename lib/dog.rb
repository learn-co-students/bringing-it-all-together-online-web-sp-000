class Dog
  attr_accessor :id, :name, :breed
  # attr_reader :id

  def initialize(id: id, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        name TEXT,
        breed TEXT,
        id INTEGER
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self
  end

  def self.create(name: name, breed: breed)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    new_dog = self.new
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end


  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)
    Dog.new(id: result[0])
  end

  def self.find_or_create_by
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name ? AND breed ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end

  def find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(result[0], result[1], result[2])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE name = ?"
    DB[:conn].execute(sql, self.name, self.breed)
  end

end

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      new_dog = DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  # Dog .create takes in a hash of attributes and uses metaprogramming to create a new dog object.
  # Then it uses the #save method to save that dog to the database
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  # creates an instance with corresponding attribute values based on returned row from db
  def self.new_from_db(result)
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    self.new_from_db(result)
  end

  # creates an instance of a dog if it does not already exist
  # when two dogs have the same name and different breed, it returns the correct dog
  # when creating a new dog with the same name as persisted dogs, it returns the correct dog
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      # dog_result = [1, "teddy", "cockapoo"]
      dog_result = dog[0]
      dog = Dog.new(id: dog_result[0], name: dog_result[1], breed: dog_result[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  # returns an instance of dog that matches the name from the DB
  def self.find_by_name(name)
    sql = ("SELECT * FROM dogs WHERE name = ? LIMIT 1")

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

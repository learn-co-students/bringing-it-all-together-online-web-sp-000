class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    # creates the dogs table in the database
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def save
    # returns an instance of the dog class
    # saves an instance of the dog class to the database
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES(?, ?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.drop_table
    # drops the dogs table from the database
    sql = "DROP TABLE dogs;"
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    # takes in a hash of attributes and uses metaprogramming to create a new dog object.
    # then it uses the #save method to save that dog to the database
    # returns a new dog object
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  def self.new_from_db(row)
    # creates an instance with corresponding attribute values
    them_dogs = self.new(id: row[0], name: row[1], breed: row[2])
    them_dogs
  end

  def self.find_by_id(id)
    # returns a new dog object by id
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id).flatten
      self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    # creates an instance of a dog if it does not already exist
    # when two dogs have the same name and different breed, it returns the correct dog
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
   if !dog.empty?
     dog = self.new_from_db(dog[0])
   else
     dog = self.create(name: name, breed: breed)
   end
   dog
  end

  def self.find_by_name(name)
    # returns an instance of dog that matches the name from the DB
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).flatten
      self.new_from_db(row)
  end

  def update
    # updates the record associated with a given instance
    sql = <<-SQL
    UPDATE dogs
    SET name = ?,
      breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

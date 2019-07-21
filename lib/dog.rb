class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
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
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"

    DB[:conn].execute(sql, self.name, self.breed)
    # binding.pry
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM DOGS;")[0][0]
    self
  end

  def self.create(dog_attributes)
    new_dog = self.new(dog_attributes)
    new_dog.save
  end

  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    self.new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.find_or_create_by(dog_attributes)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL

    dog = DB[:conn].execute(sql, dog_attributes[:name], dog_attributes[:breed])
    # binding.pry
    if !dog.empty?
      dog_data = dog[0]
      new_dog = self.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      new_dog = self.create(dog_attributes)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    dog = DB[:conn].execute(sql, name)
    self.new_from_db(dog[0])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
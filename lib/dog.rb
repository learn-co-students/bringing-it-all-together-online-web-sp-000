class Dog
  attr_accessor :name, :breed, :id

  # def initialize(id: nil, name:, breed:)
  #   @id, @name, @breed = id, name, breed
  # end

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(arr)
    arr.each do |dog|
      Dog.create(dog)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name).flatten
    new_dog = Dog.new(result)
    new_dog
  end

  def self.find_by_id(id)
    #return new dog object by id
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id).flatten
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name, breed)
    new_dog.save
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def find_or_create_by(name)
  end
end

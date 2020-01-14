class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_traits)

    if dog_traits[:id].nil?
      @id = nil
    else
      @id = dog_traits[:id]
    end

    @name = dog_traits[:name]
    @breed = dog_traits[:breed]
  end


  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end


  def self.drop_table
      sql =  <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
      DB[:conn].execute(sql)
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


  def self.create(dog_traits)
    dog = Dog.new(dog_traits)
    dog.save
    dog
  end


  def self.new_from_db(row)

    dog_traits = {id: row[0], name: row[1], breed: row[2]}

    new_dog = self.new(dog_traits)
    new_dog  # return the newly created instance
  end


  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    results = {id: result[0], name: result[1], breed: result[2]}
    found_dog = Dog.new(results)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

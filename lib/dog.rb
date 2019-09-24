class Dog

  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
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
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new({:name => name, :breed => breed})
    new_dog.save
    new_dog
  end

  def self.new_from_db (row)
    self.new({:id => row[0], :name => row[1], :breed => row[2]})
  end

  def self.find_by_id (num)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", num).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by (name:, breed:)
    found_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if found_dog.empty?
      found_dog = self.create({:name => name, :breed => breed})
    else
      found_dog = self.new_from_db(found_dog[0])
    end
    found_dog
  end

  def self.find_by_name (name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end

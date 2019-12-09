class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil) #nil because if we don't provide id database will do it for us.
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table #method called to create database table
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", @name, @breed) #pulling from initialize
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    return self
  end

  def self.create(attributes)
    Dog.new(attributes).save
  end

#row = [1, "Pat", "poodle"]
#name:, breed:, id: nil

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

#dog_data =[[1, "Kevin", "shepard"]] return value of method below
  def self.find_by_id(id)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id) #fill in question mark with what comes after, in this case id
    new_from_db(dog_data[0])
  end

  def self.find_or_create_by(name:, breed:)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if dog_data.empty?
      create(name: name, breed: breed)
    else
      self.new_from_db(dog_data[0])
    end
  end

  def self.find_by_name(name)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? ", name)
    return self.new_from_db(dog_data[0])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ? WHERE id = ?", @name, @id) #coming from instance, so instance variables
  end

end

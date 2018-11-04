class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash, id: nil)
    hash.each do |key,value|
      self.send("#{key}=", value)
    end
    @id = id
  end

  def save
    if self.id
      udpate
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
    end
    self
  end

  def self.create(name:, breed:)
    Dog.new({name: name, breed: breed}).save
  end

  def self.find_by_name(name)
    search = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
    self.new_from_db(search)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", @name, @breed, @id)
  end

  def self.find_or_create_by(name:, breed:)
    search = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if search.empty?
      Dog.create(name: name, breed: breed)    
    else
      Dog.new_from_db(search.first)
    end 
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten    
    Dog.new_from_db(row)
  end

  def self.new_from_db(row)
    dog = Dog.new({name: row[1], breed: row[2]})
    dog.id = row[0]
    dog
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")    
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)    
  end
  
end
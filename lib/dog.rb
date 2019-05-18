class Dog 
  
  attr_reader :id, :breed
  attr_accessor :name
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name 
    @breed = breed
  end
  
  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES(?, ?)
      SQL
    
      DB[:conn].prepare(sql).execute(self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
      self
    else
      self.update
    end
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    
    DB[:conn].prepare(sql).execute(self.name, self.breed, self.id)
  end
  
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
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
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    result = DB[:conn].prepare(sql).execute(id).map{ |x| self.new_from_db(x) }[0]
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.name = ?
    SQL
    
    result = DB[:conn].prepare(sql).execute(name).map{ |x| self.new_from_db(x) }[0]
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if dog.empty?
      self.create(name: name, breed: breed)
    else 
      new_from_db(dog[0])
    end
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
    
end
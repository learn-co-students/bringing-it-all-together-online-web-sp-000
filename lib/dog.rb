class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    hash.each do |k,v|
        self.send(("#{k}="), v)
    end
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
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

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
  end

  def self.new_from_db(row)
    dog_hash = {name: row[1], breed: row[2], id: row[0]}
    Dog.new(dog_hash)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).map do |row|
      Dog.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |row|
      Dog.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !dog.empty?
      dog_hash = {id: dog[0][0], name: dog[0][1], breed: dog[0][2]}
      Dog.new(dog_hash)
    else
      Dog.create({name: hash[:name], breed: hash[:breed]})
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
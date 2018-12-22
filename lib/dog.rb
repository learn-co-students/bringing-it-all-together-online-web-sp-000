class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name: nil, breed: nil , id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =<<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"

    DB[:conn].execute(sql)
  end

  def save
    sql =<<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    return self
  end

  def self.create(hash)
    #hash = {:name=>"Ralph", :breed=>"lab"}
    dog = Dog.new()
    hash.each do |key, value|
      dog.send("#{key}=", value)
    end
    dog.save
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])

    if dog.empty?
      self.create(hash)
    else
      self.find_by_id(dog[0][0])
    end
  end

  def self.find_by_name(name)
    sql =<<-SQL
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

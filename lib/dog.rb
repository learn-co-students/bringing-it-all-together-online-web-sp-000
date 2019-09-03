class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save

    sql = <<-SQL
    INSERT INTO dogs(name, breed) VALUES(?,?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT * FROM dogs GROUP BY id HAVING MAX(id)").flatten[0]
    self
  end

  def self.create(hash)
    newDog = Dog.new(hash)
    newDog.save
    newDog

  end

  def self.new_from_db(row)
    #puts row
    hash = {:id => row[0], :name => row[1], :breed => row[2]}
    newDog = Dog.new(hash)

  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id)[0]
    hash = {:id => row[0], :name => row[1], :breed => row[2]}
    Dog.new(hash)

  end
  def self.find_or_create_by(hash)
    #puts hash
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", hash[:name], hash[:breed])[0]
    dog = nil
    if !row.nil?
      dog_hash = {:id => row[0], :name => row[1], :breed => row[2]}
      dog = Dog.new(dog_hash)
    else
      dog = self.create(hash)
      dog.save
      dog.id = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", hash[:name], hash[:breed])[0][0]
    end

    dog

  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name)[0]
    if row.empty?
      puts "No result."
    else
      hash = {:id => row[0], :name => row[1], :breed => row[2]}
      dog = Dog.new(hash)
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? where id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end

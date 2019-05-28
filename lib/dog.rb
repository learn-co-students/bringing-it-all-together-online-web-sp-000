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
      DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
        sql = <<-SQL
      SELECT *FROM dogs
      WHERE name = ?
      SQL
      row = DB[:conn].execute(sql, name)
      self.new_from_db(row)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
      self
    end

    def self.create(name:, breed:)
      new_dog = Dog.new(name: name, breed: breed)
      new_dog.save
    end

    def update
      sql = <<-SQL
      UPDATE  dogs SET name = ?, breed = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_by_id(id)
      sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id).flatten
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
      dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
      if !dog_row.empty?
        dog = Dog.new(name: dog_row[1], breed: dog_row[2], id: dog_row[0])
      else
        dog = Dog.create(name: dog_row[1], breed: dog_row[2])
      end
      dog
    end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL
    dog_row = DB[:conn].execute(sql, name).flatten
    Dog.new(name: dog_row[1], breed: dog_row[2], id: dog_row[0])
  end
end

require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(id:nil,name:,breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(name:,breed:)
    self.new(name:name,breed:breed).tap {|dog| dog.save}
  end

  def self.new_from_db(row)
    self.new(
      id:row[0],
      name:row[1],
      breed:row[2]
    )
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
    SQL

    self.new_from_db(DB[:conn].execute(sql,id)[0])

  end

  def self.find_or_create_by(name:,breed:)
    
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"

    dog = DB[:conn].execute(sql,name,breed)

    if dog.empty?
      self.create(name:name,breed:breed)
    else
      self.new_from_db(dog.first)
    end
    
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?;
    SQL

    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name,breed)
    VALUES (?,?);
    SQL

    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self

  end

  def update
    if self.id
      self.save
    else
      sql = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?;
      SQL

      DB[:conn].execute(sql,self.name,self.breed,self.id)
    end
  end

end
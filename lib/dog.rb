class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: id, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        name TEXT,
        breed TEXT,
        id INTEGER
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

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self
  end



  # def self.new_from_db(row)
  #   new_dog = self.new
  #   new_dog.name = row[0]
  #   new_dog.breed = row[1]
  #   new_dog.id = row[2]
  #   new_dog
  # end


end

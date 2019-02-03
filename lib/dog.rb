class Dog
  attr_accessor :id, :name, :breed
  def initialize(**attr)
    @id = attr[:id]
    @name = attr[:name]
    @breed = attr[:breed]
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def save
    if @id
      sql = <<-SQL
        UPDATE dogs SET name=?, breed=? WHERE id=?
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.create(**attr)
    new_dog = new(attr)
    new_dog.save
    new_dog
  end
  
    
  def self.new_from_db(row)
    new({
      :id => row[0],
      :name => row[1],
      :breed => row[2]
      })
  end
  
  def self.find_by_id(id)
    sql = <<-SQL 
         SELECT * FROM dogs WHERE dogs.id==? LIMIT 1
       SQL
    student_row = DB[:conn].execute(sql, id)
    new_from_db(student_row[0])
  end
  
  def self.find_by_name(name)
    sql = <<-SQL 
           SELECT * FROM dogs WHERE dogs.name==? LIMIT 1
         SQL
    student_row = DB[:conn].execute(sql, name)
    new_from_db(student_row[0])
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name=?, breed=? WHERE id=?
      SQL
    DB[:conn].execute(sql, @name, @breed, @id)
  end
  
  def self.find_or_create_by(dog)
    sql = <<-SQL 
         SELECT * FROM dogs WHERE dogs.name==? AND dogs.breed=? LIMIT 1
       SQL
    dog_row = DB[:conn].execute(sql, dog[:name], dog[:breed])
   
    return new_from_db(dog_row[0]) if dog_row[0]
    create(dog)
  end
end
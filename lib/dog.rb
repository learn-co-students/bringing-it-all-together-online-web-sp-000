class Dog
  attr_accessor :id, :name, :breed
  def initialize(args)
    args.each {|key, value| self.send("#{key}=", value)}
  end
  def save
    sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?,?)
          SQL
    DB[:conn].execute(sql, @name, @breed)[0]
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    puts @id
    return self
  end
  def self.create_table
    sql = <<-SQL
            CREATE TABLE dogs (
              id int PRIMARY_KEY,
              name string,
              breed string
            )
          SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql = <<-SQL
            DROP TABLE IF EXISTS dogs
          SQL
    DB[:conn].execute(sql)
  end

  def self.create(args)
    dog = Dog.new(args)
    dog.save
    return dog
  end

  def self.new_from_db(row)
    dog = Dog.new({id: row[0], name: row[1], breed: row[2]})
    return dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT * FROM dogs WHERE id=? LIMIT 1
          SQL
    dog = Dog.new_from_db(DB[:conn].execute(sql, id)[0])
    return dog
  end
  def self.find_or_create_by(args)
    sql = <<-SQL
            SELECT * FROM dogs WHERE name=? AND breed=?
          SQL
    dog_row = DB[:conn].execute(sql, args[:name], args[:breed])
    puts dog_row
    if (dog_row.count < 1)
      dog = Dog.create(args)
    else
      dog = Dog.new_from_db(dog_row[0])
    end
    puts dog.id
    return dog
  end
  def self.find_by_name(name)
    sql = <<-SQL
            SELECT * FROM dogs WHERE name=? LIMIT 1
          SQL
    dog = Dog.new_from_db(DB[:conn].execute(sql, name)[0])
    return dog
  end
  def update
    sql = <<-SQL
            UPDATE dogs SET name=?, breed=? WHERE id=?
          SQL
    DB[:conn].execute(sql, @name, @breed, @id)
  end

end

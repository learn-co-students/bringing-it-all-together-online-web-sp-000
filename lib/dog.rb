class Dog

  attr_accessor :name, :breed, :id

  def initialize(arg)
        arg.each_pair {|key, value| self.send(("#{key}="), value)}
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

   if self.id
      self.update

   else

    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

   end
     self
  end

  def update

    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

  def self.create(arg)

    self.new(arg).save

  end

  def self.find_by_id(id)

    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL

    self.new_from_db(DB[:conn].execute(sql, id)[0])

  end

  def self.find_or_create_by(arg)

    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", arg[:name], arg[:breed])[0]

    dog.respond_to?(:'empty?') ? self.new_from_db(dog) : self.create(arg)

  end

  def self.new_from_db(arg)

    dog = {}

    dog[:id] = arg[0]
    dog[:name] = arg[1]
    dog[:breed] = arg[2]

    self.new(dog)

  end

  def self.find_by_name(name)

    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    self.new_from_db(DB[:conn].execute(sql, name)[0])

  end




end

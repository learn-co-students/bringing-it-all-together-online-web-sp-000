class Dog
  attr_accessor :id, :name, :breed

  def initialize(info_hash)
  	info_hash.each{|key, value| self.send(("#{key}="), value)}
  end

  def self.create(info_hash)
    new_dog = Dog.new(info_hash)
    new_dog.save
  end

  def self.new_from_db(row)
    new_student = Dog.new(self.create_info_hash_from_row(row))
  end

  def self.create_info_hash_from_row(array)
    hash = {}
    hash[:id] = array[0]
    hash[:name] = array[1]
    hash[:breed] = array[2]
    hash
  end

  def self.create_info_hash_from_text(name, breed)
    hash = {}
    hash[:name] = name
    hash[:breed] = breed
    hash
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = #{id}
    SQL
    return_data = DB[:conn].execute(sql)
    new_dog = Dog.new(self.create_info_hash_from_row(return_data[0]))
    new_dog
  end

  def self.find_or_create_by(info)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    return_data = DB[:conn].execute(sql, info[:name], info[:breed])
    return_data.size > 0 ? (new_dog = self.new_from_db (return_data[0])) : (new_dog = Dog.new(self.create_info_hash_from_text(info[:name], info[:breed])).save)
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    return_data = DB[:conn].execute(sql, name)
    new_dog = self.new_from_db (return_data[0])
    new_dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
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

end

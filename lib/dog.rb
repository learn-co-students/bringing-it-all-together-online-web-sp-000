class Dog
  attr_accessor :id, :name, :breed

  def initialize(hash)
    hash.each {|k, v| self.send(("#{k}="), v)}
    self.id ||= nil
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY)
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
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowId() FROM dogs')[0][0]
    self
  end

  def self.create(hash)
    new = Dog.new(hash)
    new.save
    new
  end

  def self.new_from_db(array)
    hash = {
      :id => array[0],
      :name => array[1],
      :breed => array[2]
    }
    self.new(hash)
  end

  def self.find_by_id(rec_id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    DB[:conn].execute(sql, rec_id).map do |r|
      self.new_from_db(r)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    record = DB[:conn].execute(sql, name, breed).first
    if record
      new_dog = self.new_from_db(record)
    else
      new_dog = self.create({:name => name, :breed => breed})
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |r|
      self.new_from_db(r)
    end.first
  end

end

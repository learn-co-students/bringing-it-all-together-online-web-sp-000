class Dog
  attr_accessor :id, :name, :breed

  def initialize(hash)
    hash.each {|k, v| self.send(("#{k}="), v)}
    self.id ||= nil
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

end

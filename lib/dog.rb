class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, breed: nil, name: nil)
    @id = id
    @name  = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def save
    if @id.nil?
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    else
      self.update
    end
    self
  end

  def update
    DB[:conn].execute('UPDATE dogs set name = ?, breed = ? WHERE id = ?', @name, @breed, @id)
  end

  def self.create(hash)
    self.new.tap do |object|
      hash.each do |att, value|
        object.send("#{att}=", value)
      end
      object.save
    end
  end

  def self.new_from_db(row)
    new_dog = self.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id).first
    self.new_from_db(row)
  end

  def self.find_or_create_by(hash)
    dog_data = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', hash[:name], hash[:breed])
    if dog_data.empty?
      self.create(hash)
    else
      self.new_from_db(dog_data.first)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    dog_data = DB[:conn].execute(sql, name).first
    self.new_from_db(dog_data)
  end
end

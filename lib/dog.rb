class Dog
attr_accessor :id, :name, :breed

def initialize(hash)
  hash.each do |k, v|
    self.send(("#{k}="), v)
  end
    self.id ||= nil
end
def self.create_table
 sql = <<-SQL
 CREATE TABLE IF NOT EXISTS dogs (
   id INTEGER PRIMARY KEY,
   name TEXT,
   breed TEXT)
  SQL
  DB[:conn].execute(sql)
end
def self.drop_table
  DB[:conn].execute("DROP TABLE dogs")
end
def save
  if self.id
    self.update
  else
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  self
end
def self.create(hash)
  dog = Dog.new(hash)
  dog.save
end
def self.new_from_db(row)
  dog_hash = {
    :id => row[0],
    :name => row[1],
    :breed => row[2]
  }
  self.new(dog_hash)
end

def self.find_by_id(id)
  sql = <<-SQL
  SELECT * FROM dogs WHERE id = ?
  SQL
  DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
  end.first
end

def self.find_or_create_by(name:, breed:)
  sql = <<-SQL
  SELECT * FROM dogs WHERE name = ? AND breed = ?
  SQL
  dog = DB[:conn].execute(sql, name, breed).first
  if dog
    doggy = self.new_from_db(dog)
  else
    doggy = self.create({:name => name, :breed => breed})
  end
  doggy
end
def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM dogs WHERE name = ?
  SQL
  DB[:conn].execute(sql, name).map do |row|
    dog = self.new_from_db(row)
  end.first
end
def update
  sql = <<-SQL
  UPDATE dogs SET name = ?, breed = ? WHERE id = ?
  SQL
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end


end

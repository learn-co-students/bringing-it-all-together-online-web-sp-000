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


end

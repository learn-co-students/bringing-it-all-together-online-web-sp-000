class Dog
attr_accessor :name,:breed,:id

def initialize(hash)
  hash.each {|key,value|self.send("#{key}=",value)}
  @id||=nil
 end

 def self.create_table
    sql=<<-SQL
       CREATE TABLE dogs(
         id INTEGER PRIMARY KEY,
         name TEXT,
         breed TEXT
       );
    SQL

    DB[:conn].execute(sql)

end

 def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
end

def save
  sql=<<-SQL
    INSERT INTO dogs (name,breed) VALUES (?,?)
  SQL

  DB[:conn].execute(sql,self.name,self.breed)
  self.id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end


def self.create(hash)
  dog=Dog.new(hash)
  dog.save
  dog
end

def self.find_by_id(id)
   sql=<<-SQL
      SELECT * FROM dogs WHERE id=?
   SQL
   #DB[:conn].results_as_hash = true
   binding.pry
   hash=DB[:conn].execute(sql,id)[0]
   Dog.new(hash)
end

end

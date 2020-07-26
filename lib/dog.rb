require 'pry'

class Dog
    attr_accessor :name,:breed,:id
    def initialize(id:nil,name:"",breed:"")
        @name=name
        @breed=breed
        @id=id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end
    
    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        # creates a student with two attributes, name and grade, and saves it into the students table.
        # binding.pry
        inst = self.new(name:hash[:name], breed:hash[:breed])
        inst.save
        # inst
      end
      
  def self.new_from_db(row)
    # binding.pry
    new_inst = self.new
    new_inst.id = row[0]
    new_inst.name =  row[1]
    new_inst.breed = row[2]
    new_inst  # return the newly created instance
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id=?
    LIMIT 1
    SQL
    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(hash)
    name=hash[:name]
    breed=hash[:breed]
    inst = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !inst.empty?
      inst_data = inst[0]
      inst = self.new(id:inst_data[0],name:inst_data[1], breed:inst_data[2])
    else
      inst = self.create(name: name, breed: breed)
    end
    inst
    # binding.pry
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name=?
    LIMIT 1
    SQL
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  end
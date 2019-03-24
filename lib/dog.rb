class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      create table if not exists dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      drop table if exists dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        insert into dogs(name, breed)
        values (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs").flatten[0]
    end
    self
  end

  def self.create(attr_hash)
    d = Dog.new(name:nil, breed:nil)
    attr_hash.each {|attr, val| d.send("#{attr}=", val)}
    d.save
    d
  end

  def self.find_by_id(id)
    sql = <<-SQL
      select * from dogs where id = ? limit 1
    SQL

    Dog.new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      select * from dogs where name = ? limit 1
    SQL

    Dog.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * from dogs where name = ? and breed = ? limit 1", name, breed)

    if dog.empty?
      Dog.create(name: name, breed: breed)
    else
      Dog.new_from_db(dog[0])
    end
  end

  def self.new_from_db(row)
    d = Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def update
    sql = <<-SQL
      update dogs
      set name = ?, breed = ?
      where id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end

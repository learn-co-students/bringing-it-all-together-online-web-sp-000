require 'pry'

class Dog

  ATTRIBUTES = {
    :id => "INTEGER PRIMARAY KEY",
    :name => "TEXT",
    :breed => "TEXT"
  }

  ATTRIBUTES.keys.each do |key|
    attr_accessor key
  end

  def initialize(attributes)
    attributes.each { |key, value| self.send(("#{key}="), value) }
  end

  def self.create_table_sql
    ATTRIBUTES.collect { |attr_name, schema| "#{attr_name} #{schema}"}.join(",")
  end

  def self.class_name
    self.to_s.downcase
  end

  def self.create_table
    create_table_sql = "create table " + "#{self.class_name}s" + "(" + "#{self.create_table_sql}" + ");"
    File.write("db/migrations/create_dog_table_migration.sql", create_table_sql, mod: "w")
    sql = File.read('db/migrations/create_dog_table_migration.sql')
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)  
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    !!self.id
  end

  def update
    
  end

  def self.attributes_names_for_insert
    ATTRIBUTES.keys[1..-1].join(",")
  end

  def self.bind_parameters
    ("?," * (ATTRIBUTES.keys.length-1))[0..-2]
  end

  def attribute_values
    ATTRIBUTES.keys[1..-1].collect { |attr_name| self.send(attr_name) }
  end

  def insert
    sql = <<-SQL
      INSERT INTO #{self.class.class_name}s (#{self.class.attributes_names_for_insert}) 
      VALUES (#{self.class.bind_parameters})
    SQL

    DB[:conn].execute(sql, *attribute_values)

    sql_id = <<-SQL
      SELECT * FROM #{self.class.class_name}s
      where id = last_insert_rowid()
    SQL

    db_dog_row = DB[:conn].execute(sql_id).flatten
    self.class.new_from_db(db_dog_row)  
  end


  def self.new_from_db(row)
    db_dog = Dog.new({})
    ATTRIBUTES.keys.each_with_index { |key, index|  db_dog.send("#{key}=", row[index]) }
    db_dog
  end

  def self.create(hash_attributes) 
    hash_dog = Dog.new({})
    hash_attributes.each { |key, value| hash_dog.send("#{key}=", value) }
    hash_dog.save
  end

  def self.find_by_id(id)
    sql_id = <<-SQL
      SELECT * FROM #{self.class_name}s
      where id = "#{id}"
    SQL

    db_dog_row = DB[:conn].execute(sql_id).flatten
    self.new_from_db(db_dog_row)  
  end

  def self.find_by_name(name)
    sql_name = <<-SQL
      SELECT * FROM #{self.class_name}s
      where name = "#{name}"
    SQL

    db_dog_row = DB[:conn].execute(sql_name).flatten
    self.new_from_db(db_dog_row) 
  end

  def self.find_or_create_by(name:, breed:)
    sql_name_breed = <<-SQL
      SELECT * FROM #{self.class_name}s
      where name = "#{name}" and breed = "#{breed}"
    SQL

    db_dog_row = DB[:conn].execute(sql_name_breed).flatten
    
    if db_dog_row.empty?
      self.new(self.create_hash(name, breed)).save
    else
      self.new_from_db(db_dog_row)
    end
  end

  def self.create_hash(name, breed)
    { :name => name,
      :breed => breed
    }
  end

end

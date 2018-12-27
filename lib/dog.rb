class Dog 
  ATTRIBUTES = [
      :id,
      :name,
      :breed
    ]

    
  ATTRIBUTES.each do |attribute_name|
    attr_accessor attribute_name  
  end 
  
  def initialize(hash = nil) 
    hash.each {|keys, values| self.send("#{keys}=", values)} unless hash == nil
    self.id = nil
  end
  
  def self.table_name
    "#{self.to_s.downcase}s"    
  end 
  
  def self.create_table_attributes
    ATTRIBUTES.collect do |attribute_name|
      
    end
  end 
  
  def self.create_table
    sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS #{self.table_name} (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = <<-SQL 
      DROP TABLE #{self.table_name}    
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def persisted?
    !!self.id
  end
  
  def save 
    persisted? ? update : insert
    
    self
  end
  
  def update 
    sql = <<-SQL 
      UPDATE #{self.class.table_name} SET name = ?, breed = ? WHERE ID = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def insert  
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (name, breed)
      VALUES(?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid()").flatten.first
  end
  
  def self.create(attributes_hash)
    Dog.new(attributes_hash).save
  end
  
  def self.find_by_id(id) 
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE id = ?
    SQL
    
    dog_info = DB[:conn].execute(sql, id).flatten
    Dog.new.tap do |p|
      p.id = dog_info[0]
      p.name = dog_info[1]
      p.breed = dog_info[2]
    end
  end
  
  def self.find_or_create_by(hash) 
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ? AND breed = ?    
    SQL
    
    dog_info = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
    
    if dog_info.empty?
      Dog.new(hash).save
    else 
      Dog.new.tap do |p|
        p.id = dog_info[0]
        p.name = dog_info[1]
        p.breed = dog_info[2]
      end
    end
  end
  
  def self.new_from_db(row) 
    Dog.new.tap do |object|
      object.id = row[0]
      object.name = row[1]
      object.breed = row[2]
    end
  end
  
  def self.find_by_name(name) 
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?
    SQL
    
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end
 
end
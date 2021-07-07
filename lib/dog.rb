 class Dog
  
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :breed => "TEXT"
  }

  ATTRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

  def initialize(params)
    params.each do |key, value|
      self.send "#{key}=", value
    end
  end

  def self.new_from_db(row)
    params = {}
    ATTRIBUTES.keys.each_with_index do |key, index|
      params[:"#{key}"] = row[index] 
    end
    new = self.create(params)
  end

  def self.create(params)
    new_obj = self.new(params)
    new_obj.save
    new_obj
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.table_name}(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT 
      ); 
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE #{self.table_name};"
    DB[:conn].execute(sql)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM #{self.table_name} WHERE id = ?"
    row = DB[:conn].execute(sql, id).first
    self.new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM "#{self.table_name}" WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).first
    self.new_from_db(row)
  end

  def self.find_or_create_by(params)
    params.include?(:id) ? obj = self.find_by_id(params[:id]) : obj = self.find_by_name(params[:name])
    obj.breed == params[:breed] ? obj : obj = create(params)     
  end

  def persisted?
    !!self.id
  end

  def save
    persisted? ? update : insert
    self
  end  

  def insert
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (name, breed) VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
  end

  def update
    sql = "UPDATE #{self.class.table_name} SET name = ?, breed = ? WHERE ID = ?"

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
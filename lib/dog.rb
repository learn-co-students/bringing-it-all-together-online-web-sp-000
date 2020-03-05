class Dog
  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id: @id)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
     drop_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs")
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
end

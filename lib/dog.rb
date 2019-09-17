class Dog

  attr_accessor :name, :breed, :id

  def initialize(name, breed, id = nil)
    @name = name
    @breed = breed
    @id = id
  end

  def create_table

  end

  def self.save(name, breed)
    db.execute("INSERT INTO dog (name, breed) VALUES (?, ?)", name, type)
  

end

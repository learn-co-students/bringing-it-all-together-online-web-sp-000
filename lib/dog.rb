class Dog

  attr_accessor :id, :name, :breed
  # attr_reader :id

  def initialize(id=nil, name, breed)
    @id = id
    @name = name
    @breed = breed
  end
end

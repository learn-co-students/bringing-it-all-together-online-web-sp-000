require "pry"
class Dog
  attr_accessor :id, :name, :breed  
 
def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
def self.create
  # sql<<- SQL 
  # Crate Table IF NOT EXIST Dog
  # SQL 
end
#db[:coon].execute(sql)
end
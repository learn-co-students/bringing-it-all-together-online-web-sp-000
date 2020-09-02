class Dog
  attr_reader :name, :breed

  attr_accessor :id

  def initialize(id:, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
  end

  def save
  end

  def self.drop_table
  end

  def self.create
  end

  def self.new_from_db
  end

  def self.find_by_id
  end

  def self.find_or_create_by
  end

  def self.find_by_name
  end

  def update
  end 
end

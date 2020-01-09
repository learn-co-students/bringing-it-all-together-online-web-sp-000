require 'pry'
require_relative "../config/environment.rb"
#The important concept to grasp here is the idea that we are not saving Ruby objects into our database.
# We are using the attributes of a given Ruby object to create a new row in our database table.
class Dog

  attr_accessor :name, :breed, :id # our dogs have all the required attributes and that they are readable and writable.

  def initialize(id: nil, name:, breed:) #accepts a hash or keyword argument value with key-value pairs as an argument. 
                                         #key-value pairs need to contain id, name, and breed.
    #default value of the id argument that the #initialize method takes equal to nil, so that we can create new dog instances
    # that *do not have an id value. We'll leave that up to the database to handle later on.  
    #   the id of a given record must be unique. If we could replicate a record's id, we would have a very disorganized
    # database. Only the database itself, in SQL, can ensure that the id of each record is unique.                                 
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table #we are starting with a clean database by executing the SQL command DROP TABLE IF EXISTS dogs.
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs ( 
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
#Instantiating a new instance of the Song class.
#Inserting a new row into the database table that contains the information regarding that instance.
#Grabbing the ID of that newly inserted row and assigning the given Song instance's id attribute equal to the ID of its 
#associated database table row.

#Create the dogs table.
#Create two new dogs instances.
#Use the dog.save method to persist them to the database.
  def save
    #We need our #save method to check to see if the object it is being called on has already been persisted. 
    #If so, don't INSERT a new row into the database, simply update an existing one.
    #How do we know if an object has been persisted? If it has an id that is not nil.
    # Remember that an object's id attribute gets set only once it has been INSERTed into the database.
    if self.id
      self.update
    else
    #to take the individual attributes of a given instance, in this case a dog's name and breed, and save those attributes 
    #that describe an individual dog to the database as one, single row.
    #we are going to pass in, or interpolate, the name and breed of a given dog into our heredoc by useing bound parameters ?
    # ? characters as placeholders, 
    ##execute method will take the values we pass in as an argument and apply them as the values of the question marks.
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      #At the end of our save method, we use a SQL query to grab the value of the ID column of the last inserted row, 
      #and set that equal to the given dog instance's id attribute
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    #we use keyword arguments to pass a name and bree into our .create method. We use that name and breed to instantiate
    # a new dog. Then, we use the #save method to persist that dog to the database.
    #The moment in which we create a new Dog instance with the #new method is different than the moment in which we save 
    #a representation of that dog to our database. The #new method creates a new instance of the dog class,
    # a new Ruby object. The #save method takes the attributes that characterize a given dog and saves them in a new row of
    # the dogs table in our database.
    dog = Dog.new(name: name, breed: breed)
    #We don't want to force our objects to be saved every time they are created. As our program grows and changes,
    # we may find the need to create objects and not save them. A dependency between instantiating an object and saving that
    # record to the database would preclude this. We'll keep our #initialize and #save methods separate
    dog.save
    #at the end of the method, we are returning the dog instance that we instantiated. The return value of .create should
    # always be the object that we created.
    dog
  end

 def self.find_or_create_by(name:, breed:) #Preventing Record Duplication
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          AND breed = ?
          LIMIT 1
        SQL
    #First, we query the database: does a record exist that has this name and breed?
    dog = DB[:conn].execute(sql,name,breed)
    
    if !dog.empty?
     #If  !song.empty? wll return true, we will use the returned values to
     # make a new object that Ruby can play around with, but we will not save it to the database. 
     #That re-instantiation of an existing Dog object is accomplished with these lines:
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)#takes data from row in table and turns it back into an instance of the appropriate class
    #the database is going to return an array representing a dog's data. We need a way to cast that data into the attributes
    # of a dog. This method gives that functionality. You can even think of it as new_from_array. 
    #Method return instances of the class, are known as constructors, just like .new, except that they extend the functionality
    # of .new without overwriting initialize.
    #we need to convert what the database gives us into a Ruby object. 
    #the database, SQLite in our case, will return an array of data for each row.
    #since we're retrieving data from a database, we are using new. We don't need to create records. 
    #With this method, we're reading data from SQLite and temporarily representing that data in Ruby.
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  # 3 methods to retrieve the data
  def self.all 
    #To return all the songs in the database we need to execute the SQL query: SELECT * FROM dogs.
    # Let's store that in a variable called sql using a heredoc (<<-) since our string will go onto multiple lines:
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL
    #Next, we will make a call to our database using DB[:conn]. This DB hash is located in the config/environment.rb file:
    # DB = {:conn => SQLite3::Database.new("db/songs.db")}. Notice that the value of the hash is actually a new instance of
    # the SQLite3::Database class. This is how we will connect to our database. Our database instance responds to a method
    # called execute that accepts raw SQL as a string. Let's pass in that SQL we stored above
    #This will return an array of rows from the database that matches our query. 
    #Now, all we have to do is iterate over each row and use the self.new_from_db method to create a new Ruby object
    # for each row:
    DB[:conn].execute(sql).map do |row|
    self.new_from_db(row)
  end
  
  def self.find_by_name(name)
     #we have to include a name in our SQL statement. To do this, we use a question mark where we want the name parameter
     # to be passed in, and we include name as the second argument to the execute method
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
    #.first method chained to the end of the DB[:conn].execute(sql, name).map block. The return value of the .map method 
    #is an array, and we're simply grabbing the .first element from the returned array.
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    #The best way for us to do this is to simply update all the attributes whenever we update a record.
    #Our #update method should identify the correct record to update based on the unique ID that both the dog Ruby object
    # and the dogs table row share:
    #using something changeable, like name, to identify the record we want to update, won't work
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
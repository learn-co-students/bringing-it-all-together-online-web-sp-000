class Dog
    attr_accessor :name, :breed, :id
    def initialize(hash)
        @name = hash[:name]
        @breed = hash[:breed]
        @id = hash[:id] ? hash[:id] : nil
    end 

    def self.create_table
        sql = <<-SQL 
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            ) 
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end 

    def self.new_from_db(array)
        #argument looks like this: [1, "Pat", "poodle"]
        #repackage it to hash form
        newinstance = Dog.new(id: array[0], name: array[1], breed: array[2])
        newinstance

    end 

    def self.create(hash)
        #does 2 things: intialize, save, return that new instsance
        newinstance = Dog.new(hash)
        newinstance.save
        newinstance
    end


    def self.find_by_name(name)
        #get dog row:
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
        result = DB[:conn].execute(sql, name)
        dogrow = result[0]
        #create instance from row:
        self.new_from_db(dogrow)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL
    result = DB[:conn].execute(sql, id)
    dogrow = result[0]
    #create instance from row:
    self.new_from_db(dogrow)

    end

    def self.find_or_create_by(hash)
        #hash looks like this: {name: 'teddy', breed: 'cockapoo'}
        #first find if theres a row with exact same attributes except id
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ? 
        SQL
        result = DB[:conn].execute(sql, hash[:name], hash[:breed])
        #i'm copying the structure because i'm not 100% sure what a nothing found result looks like. is it an [] or a nil thing?
        if !result.empty? #if found
            Dog.new_from_db(result[0])
        else#if empty, create
            Dog.create(hash)
        end #end if
    end

    def save #instance
        if @id #id not falsey means not nil, alreayd exist
            self.update
        else #save to database
            sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            #save id to ruby instance
            @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
        end #end if
        self
    end

    def update #instance method
        #update to the database based on whats currently on the ruby instance
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, @id)
    end



end #end class
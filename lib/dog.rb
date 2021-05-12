class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        );
      SQL
      DB[:conn].execute(sql)
    end

    def initialize(dog_hash)
        @id = dog_hash[:id]
        @name = dog_hash[:name]
        @breed = dog_hash[:breed]
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?);", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
    end

    def self.create(dog_attrs)
        # if dog_attrs[:name] is in dogs, return that dog
        this_dog = self.new(dog_attrs)
        this_dog.save
    end

    def self.new_from_db(row)
        self.new({id: row[0], name: row[1], breed: row[2]})
    end

    def self.find_by_id(id_num)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.id = ?;", id_num)
        Dog.new({id: row[0][0], name: row[0][1], breed: row[0][2]})
    end

    def self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.name = ?;", name)
        Dog.new({id: row[0][0], name: row[0][1], breed: row[0][2]})
    end

    def self.find_or_create_by(dog_attrs)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.name = ?
        SQL
        db_dog = DB[:conn].execute(sql, dog_attrs[:name])

        dog = db_dog.find{|d| d[2] == dog_attrs[:breed]}
        # binding.pry

        if dog
            # if dog && !dog.empty?
                # this_dog = self.find_by_id(dog[0]) # if dog
            # end
            this_dog = self.find_by_id(dog[0]) # if dog
        else
            this_dog = self.create({name: dog_attrs[:name], breed: dog_attrs[:breed]})
        end

        this_dog
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
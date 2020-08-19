class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
              id INTEGER PRIMARY KEY,
              name TEXT,
              breed TEXT
          )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT * 
          FROM dogs
          WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def save
    end
end
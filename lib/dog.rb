require 'pry'
require_relative "../config/environment.rb"

class Dog
    attr_accessor :id, :name, :breed

    def initialize (id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        Create Table If Not Exists dogs (
            id integer Primary key,
            name Text,
            breed Text
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "Drop Table If Exists dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            Insert Into dogs (name, breed)
            Values (?, ?)
            SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("Select last_insert_rowid() from dogs")[0][0]
        end
        self
    end
# similar to the ORM update lab but with keyword arguments
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            Select *
            From dogs
            Where id = ?
            Limit 1
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

end
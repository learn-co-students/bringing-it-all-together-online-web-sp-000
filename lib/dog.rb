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

end
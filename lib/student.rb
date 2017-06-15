require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize (name, grade, id=nil)
    self.name = name
    self.grade = grade
    if id
      @id = id
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      return self.update
    end
    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)  #returns empty array, need to get id
    new_row=DB[:conn].execute("SELECT last_insert_rowid () FROM students")[0]
    @id = new_row[0]
    self

  end

  def update
    sql = "UPDATE students SET name=?, grade=?, id=?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
    self
  end

  def self.create(name, grade)
    new_student = self.new(name,grade)
    new_student.save
  end

  def self.new_from_db(arg_arr)
    # [0] is id, [1] is name, [2] is grade
    new_student = self.new(arg_arr[1], arg_arr[2], arg_arr[0])
    
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name=?
    SQL
    new_row = DB[:conn].execute(sql, name)[0]
    new_student = self.new_from_db(new_row)
  end

end

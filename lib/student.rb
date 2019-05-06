require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    DB[:conn].execute "CREATE TABLE IF NOT EXISTS students(
                      id INTEGER PRIMARY KEY,
                      name TEXT,
                      grade TEXT
    );"
  end

  def self.all
    batch_create(DB[:conn].execute "SELECT * FROM students")
  end

  def self.drop_table
    DB[:conn].execute "DROP TABLE students"
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.batch_create(rows)
    rows.map{|row| new_from_db(row)}
  end
  
  def self.find_by_name(name)
    new_from_db(DB[:conn].execute("SELECT * FROM students WHERE name = ?;", name)[0])
  end

  def save
    if(@id)
      update
    else
      DB[:conn].execute("INSERT INTO students (name, grade) VALUES (?, ?);", @name, @grade)
      instance = Student.all.last
      @id = instance.id
      instance
    end
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?", @name, @grade, @id)
  end
end

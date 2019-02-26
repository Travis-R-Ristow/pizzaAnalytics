require 'pg'
require 'csv'

CSV.foreach("data.csv") do |row|
  puts row.inspect
end
print "\n\n"


conn = PG.connect(
  dbname: "postgres",
  port: 4720,
  user: "postgres",
  password: "admin"
)


conn.exec "DROP TABLE IF EXISTS People"
conn.exec "CREATE TABLE People(
			Id INTEGER PRIMARY KEY, 
	        Name VARCHAR(20)
        )"


i = 0
CSV.foreach("data.csv") do |row|
	conn.exec_params(
    "INSERT INTO People (id, name)
    values ($1, $2);",
    [
      i,
      row[0]
    ])
	i+=1
end


# conn.exec "INSERT INTO People VALUES(1, 'Steve')"


result = conn.exec "SELECT * FROM People"
result.each do |row|
	puts row.inspect
end
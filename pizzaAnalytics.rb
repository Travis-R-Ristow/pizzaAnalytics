require 'pg'
require 'csv'
require 'grape'
require 'sequel'


# CSV.foreach("data.csv") do |row|
#   puts row.inspect
# end
print "\n\n"


conn = PG.connect(
  dbname: "postgres",
  port: 4720,
  user: "postgres",
  password: "admin"
)


# CLEARING TABLES
conn.exec "DROP TABLE IF EXISTS Pizza"
conn.exec "DROP TABLE IF EXISTS People"

# CREATE PEOPLE's TABLE
conn.exec "CREATE TABLE People(
			Id INT PRIMARY KEY, 
			Name VARCHAR(20) UNIQUE
        )"

# FILL PEOPLE's TABLE
i = 0
CSV.foreach("data.csv") do |row|
	if i != 0	#To ignore TableHeader of CSV
		conn.exec_params(
	    	"INSERT INTO People (Id, Name)
		     VALUES ($1, $2)
		     ON CONFLICT (Name) DO NOTHING;",
		    [
		      i,
		      row[0]
		    ]
	    )
	end
	i+=1
end

tablePeople = conn.exec("SELECT * FROM People")

tablePeople.each do |row|
	puts row.inspect
end


# conn.exec "DROP TABLE IF EXISTS Pizza"

# CREATE PIZZA's TABLE
conn.exec "CREATE TABLE Pizza(
			Id INT PRIMARY KEY,
			PersonId INT REFERENCES People(Id),
			Type VARCHAR(20),
			Eaten_at DATE
        )"

puts "\n\n"
# FILL PIZZA's TABLE
i = 0
CSV.foreach("data.csv") do |row|
	if i != 0	#To ignore TableHeader of CSV
		pId = conn.exec("SELECT * FROM People WHERE name ='"+row[0]+"'")
		conn.exec_params(
	    	"INSERT INTO Pizza (Id, PersonId, Type, Eaten_at)
		     VALUES ($1, $2, $3, $4);",
		    [
		      i,
		      pId[0]['id'],
		      row[1],
		      row[2]
		    ]
	    )
	end
	i+=1
end

tablePizza = conn.exec "SELECT * FROM Pizza"

tablePizza.each do |row|
	puts row.inspect
end

# GLOBAL VARIABLES 
$peopleJSON = []
	allPeople = conn.exec "SELECT * FROM People"
	allPeople.each do |row|
		$peopleJSON << row["name"]	# COULD BE PUT IN THE SAME PEOPLES LOOP AS ABOVE
	end

$pizzaJSON = []
	allPizza = conn.exec "SELECT * FROM Pizza"
	allPizza.each do |row|
		$pizzaJSON << row	# COULD BE PUT IN THE SAME PIZZA LOOP AS ABOVE
	end


# GRAPE MODULE FOR GET ROUTES
module App
	class App < Grape::API
		version 'v1', using: :header, vendor: 'API'
		 format :json
		 # prefix :api

		get '/' do
			"Hey Puppies"
		end

		get '/people' do
			$peopleJSON
		end

		get '/pizzas' do
			$pizzaJSON
		end

	end
end
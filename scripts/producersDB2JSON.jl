#!/bin/env julia

######### https://cotesdarmor.fr/actualites/une-carte-pour-consommer-local #############

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
using ArgParse
import JSON, MySQL, DBInterface


cnx = DBInterface.connect(MySQL.Connection, "Localhost", "root", "osiris")


function loadArea(departement::Int64)
	println("loadArea(",departement,")")
	sql = "Select latitude lat, longitude lng, name, website web, COALESCE (shortDescription, `text`) txt, wikiTitle wiki, phoneNumber tel, postCode, city, address addr, categories cat, email
		from openproduct.producer
		where postCode="*string(departement)*" or (postCode>="*string(departement)*"000 and postCode<"*string(departement+1)*"000)"
	producers = DBInterface.execute(cnx,sql)
	filepath = "../public/data/producers_"*string(departement)*".json"
	file = open(filepath, "w") do file
		write(file, "[\n")
		sep = ""
		for producer in producers
		    print(".")
		    line = sep*JSON.json(producer)*"\n"
		    write(file, line)
		    sep = ","
		end
		write(file, "]")
	end
	println(" File '"*filepath*"' writed.")
end

if length(ARGS)>0
	for area in ARGS
		loadArea(parse(Int64, area))
	end
else
	areas::Vector{Int} = []
	sql = "Select distinct if(postCode>200, cast(postCode/1000 as int), postCode) as area
		from openproduct.producer"
	areasRes = DBInterface.execute(cnx,sql)
	for area in areasRes
		push!(areas, area[1])
	end
	println(areas)
	for area in areas
		loadArea(area)
	end
end

DBInterface.close!(cnx)


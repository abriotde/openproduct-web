#!/bin/env julia

######### https://cotesdarmor.fr/actualites/une-carte-pour-consommer-local #############

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
import JSON, MySQL, DBInterface


cnx = DBInterface.connect(MySQL.Connection, "Localhost", "root", "osiris")


function loadArea(departement::Int64)
	println("loadArea(",departement,")")
	sql = "Select latitude, longitude, name, website, COALESCE (shortDescription, `text`), wikiTitle, categories
		from openproduct.producer
		where postCode="*string(departement)*" or (postCode>="*string(departement)*"000 and postCode<"*string(departement+1)*"000)"
	producers = DBInterface.execute(cnx,sql)
	filepath = "../public/producers_"*string(departement)*".json"
	file = open(filepath, "w") do file
		write(file, "[\n")
		sep = ""
		for producer in producers
		    print(".")
		    text = producer[3]
		    website = producer[4]
		    if website!=""
		        text = "<a href='"*website*"'>"*text*"</a>"
		    end
		    descr = producer[5]
		    if descr!=""
		        text = text*"<p>"*descr*"</p>"
		    end
		    line = sep*JSON.json([producer[1],producer[2],text,producer[6],producer[7]])*"\n"
		    write(file, line)
		    sep = ","
		end
		write(file, "]")
	end
	println(" File '"*filepath*"' writed.")
end

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


DBInterface.close!(cnx)

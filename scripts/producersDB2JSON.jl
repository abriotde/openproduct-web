#!/bin/env julia

######### https://cotesdarmor.fr/actualites/une-carte-pour-consommer-local #############

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
using ArgParse
import JSON, MySQL, DBInterface


cnx = DBInterface.connect(MySQL.Connection, "Localhost", "root", "osiris")


function loadArea(departement::Int64)
	println("loadArea(",departement,")")
	departementStr = string(departement)
	sql = "Select latitude lat, longitude lng, name, website web, COALESCE (shortDescription, `text`) txt, wikiTitle wiki, phoneNumber tel, postCode, city, address addr, categories cat, if(sendEmail is NULL or sendEmail!='wrongEmail',email,'') as email, if(status in ('actif'), false, true) as suspect
		from openproduct.producer
		where (postCode="*departementStr*" or (postCode>="*departementStr*"000 and postCode<"*string(departement+1)*"000))
			AND latitude is not null AND longitude is not null
			AND status in ('actif','unknown')"
	producers = DBInterface.execute(cnx,sql)
	filepath = "../public/data/producers_"*departementStr*".json"
	file = open(filepath, "w") do file
		write(file, "{\"id\":"*departementStr*",\"producers\":[\n")
		sep = ""
		for producer in producers
		    print(".")
		    line = sep*JSON.json(producer)*"\n"
		    write(file, line)
		    sep = ","
		end
		write(file, "]}")
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
		if area[1] === missing
			println("Error : null postCode in openproduct.producer")
			exit()
		end
		push!(areas, area[1])
	end
	println(areas)
	for area in areas
		loadArea(area)
	end
end

DBInterface.close!(cnx)


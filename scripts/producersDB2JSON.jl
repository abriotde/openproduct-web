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
	sql = "Select id, latitude lat, longitude lng, name,
			COALESCE (shortDescription, `text`) txt, wikiTitle wiki,
			postCode, city, address addr, categories cat,
			phoneNumber tel,
			if(sendEmail is NULL or sendEmail!='wrongEmail',email,'') as email,
			if(websiteStatus in ('ok','400'), website, '') as web,
			if(status in ('actif'), 0, 1) as suspect
		from openproduct.producer
		where (postCode="*departementStr*" or (postCode>="*departementStr*"000 and postCode<"*string(departement+1)*"000))
			AND latitude is not null AND longitude is not null
			AND status in ('actif','unknown','to-check')"
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


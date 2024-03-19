#!/bin/env julia
#=
	Script for regenerate static JSON data for producers : public/data/producers_AREA.json
=#

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
using ArgParse
import JSON, MySQL, DBInterface

include("connect.jl")


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
		from producer
		where postCode IS NOT NULL AND (postCode="*departementStr*" or (postCode>="*departementStr*"000 and postCode<"*string(departement+1)*"000))
			AND latitude is not null AND longitude is not null
			AND status in ('actif','unknown','to-check')"
	producers = DBInterface.execute(dbConnection,sql)
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
	sql = "SELECT distinct if(postCode>200, cast(postCode/1000 as int), postCode) as area
		from producer
		WHERE postCode IS NOT NULL"
	areasRes = DBInterface.execute(dbConnection,sql)
	for area in areasRes
		if area[1] === missing
			println("Error : null postCode in producer")
			exit()
		end
		push!(areas, area[1])
	end
	println(areas)
	for area in areas
		loadArea(area)
	end
end

DBInterface.close!(dbConnection)


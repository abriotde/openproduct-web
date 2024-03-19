#!/bin/env julia

######### https://cotesdarmor.fr/actualites/une-carte-pour-consommer-local #############

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
using ArgParse
import JSON, MySQL, DBInterface

include("connect.jl")


function producersExportJSON(filepath::String, area::Int64=0)
	println("producersExportJSON(",filepath,", ",area,")")
	areaStr = string(area)
	sql = "Select id, latitude lat, longitude lng, name,
			COALESCE(`text`, shortDescription) txt, wikiTitle wiki,
			shortDescription job,
			postCode, city, address addr, categories cat,
			phoneNumber tel, phoneNumber2 tel2,
			if(sendEmail is NULL or sendEmail!='wrongEmail',email,'') as email,
			if(websiteStatus in ('ok','400'), website, '') as web,
			if(status in ('actif'), 0, 1) as suspect
		from producer
		where latitude is not null AND longitude is not null
			AND status in ('actif','unknown','to-check')"
	if area>0
		sql *= " AND postCode IS NOT NULL AND (postCode="*areaStr*" or (postCode>="*areaStr*"000 and postCode<"*string(area+1)*"000))"
	end
	producers = DBInterface.execute(dbConnection,sql)
	file = open(filepath, "w") do file
		write(file, "{\"id\":"*areaStr*",\"producers\":[\n")
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
function getAllAreas()
	areas::Vector{Int} = []
	sql = "SELECT distinct if(postCode>200, cast(postCode/1000 as int), postCode) as area
		from producer
		WHERE postCode IS NOT NULL
		ORDER BY area"
	areasRes = DBInterface.execute(dbConnection,sql)
	for area in areasRes
		if area[1] === missing
			println("Error : null postCode in producer")
			exit()
		end
		push!(areas, area[1])
	end
	areas
end

if length(ARGS)>0
	for area in ARGS
		producersExportJSON(parse(Int64, area))
	end
else
	areas = getAllAreas()
	println(areas)
	for area in areas
		areaStr = string(area)
		filepath = "../public/data/producers_"*areaStr*".json"
		producersExportJSON(filepath, area)
	end
end
producersExportJSON("../public/api/export.json")

DBInterface.close!(dbConnection)


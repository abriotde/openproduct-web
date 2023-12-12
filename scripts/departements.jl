#!/bin/env julia

######### https://cotesdarmor.fr/actualites/une-carte-pour-consommer-local #############

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
import JSON, MySQL, DBInterface, CSV

mutable struct Area
	nbhd::Array{Int}
	min::Tuple{Float64, Float64}
	max::Tuple{Float64, Float64}
	function Area()
		new([], (100.0,100.0), (100.0,100.0))
	end
end


departements = Dict{Int64, Area}()


# Get neighbouring
neighbouringFile = "../../openproduct-docs/sources/voisinagesDepartementsFrançais.csv";
csv_reader = CSV.File(neighbouringFile, delim=';', comment="#")
for row in csv_reader
	# println(row)
	idArea = row[:Departement]
	area = Area()
	for neighbour in row
		# println(neighbour)
		neigh = if typeof(neighbour)!=Int64
			try
				parse(Int64, neighbour)
			catch e
				0
			end
		else
			neighbour
		end
		if neigh>0 && neigh!=idArea
			push!(area.nbhd, neigh)
		end
	end
	sort!(area.nbhd) # Necessary to help checkNeighbouring() function in map.js
	departements[idArea] = area;
end
# println(departements)

# Get min/max points
cnx = DBInterface.connect(MySQL.Connection, "Localhost", "root", "osiris")
sql = "select min(latitude), max(latitude), min(longitude), max(longitude), if(postCode>200, floor(postCode/1000), postCode) as area
from openproduct.producer
group by area"
rows = DBInterface.execute(cnx,sql)
for row in rows
	id = row[5]
	try
		area = departements[id]
		area.min = (row[1], row[3])
		area.max = (row[2], row[4])
		departements[id] = area
	catch err
		if isa(err, KeyError)
			println("ERROR : No departement : ",id)
		else rethrow(err)
		end
	end
end
DBInterface.close!(cnx)
println(departements)

# Write output
filepath = "../public/departements.json"
file = open(filepath, "w") do file
    write(file, JSON.json(departements))
end
println(" File '"*filepath*"' writed.")


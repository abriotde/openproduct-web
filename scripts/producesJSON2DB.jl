#!/bin/env julia

######### https://cotesdarmor.fr/actualites/une-carte-pour-consommer-local #############

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
using ArgParse
import JSON, MySQL, DBInterface


cnx = DBInterface.connect(MySQL.Connection, "Localhost", "root", "osiris")


function loadProduces(lang::String)
	println("loadArea(",lang,")")
	sql = "Select id, category as cat, "*lang*" as name
		from openproduct.produce
		ORDER BY category, "*lang
	produces = DBInterface.execute(cnx,sql)
	filepath = "../public/data/produces_"*lang*".json"
	file = open(filepath, "w") do file
		write(file, "{\"lang\":\""*lang*"\",\"produces\":[\n")
		sep = ""
		for produce in produces
			if produce[:cat]!==missing
				print(".")
				line = sep*JSON.json(produce)*"\n"
				write(file, line)
				sep = ","
			end
		end
		write(file, "]}")
	end
	println(" File '"*filepath*"' writed.")
end


loadProduces("fr")

DBInterface.close!(cnx)


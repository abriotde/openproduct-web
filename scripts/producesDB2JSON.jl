#!/bin/env julia

######### https://cotesdarmor.fr/actualites/une-carte-pour-consommer-local #############

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
using ArgParse
import JSON, MySQL, DBInterface

include("connect.jl")

function exportProduces2JSON(lang::String)
	println("exportProduces2JSON(",lang,")")
	sql = "Select id, category as cat, "*lang*" as name
		from produce
		ORDER BY category, "*lang
	produces = DBInterface.execute(dbConnection, sql)
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

function exportProductLink2JSON(product::Int=0)
	println("exportProductLink2JSON(",product,")")
	old_produce = 0
	old_file = 0
	sep = ""
	filepath = ""
	file = 0
	sql = "SELECT producer, produce 
	FROM product_link "
	if product>0 
		sql *= " WHERE produce="*product
	end
	sql *= " ORDER BY produce, producer"
	links = DBInterface.execute(dbConnection, sql)
	for link in links
		producer = link[:producer]
		produce = link[:produce]
		if produce!==missing
			if old_produce!=produce # We change produce_id
				old_produce = produce
				if old_file>0 # so close previous file
					write(file, "}")
					close(file)
					println(" File '"*filepath*"' writed.")
				end
				# Open new file
				filepath = "../public/data/productLink_"*string(produce)*".json"
				file = open(filepath, "w")
				old_file = 1
				write(file, "{")
				sep = ""
			end
			print(".")
			line = sep*"\"m"*string(producer)*"\":true\n"
			write(file, line)
			sep = ","
		end
	end
	if old_file>0 # so close previous file
		write(file, "}")
		close(file)
		println(" File '"*filepath*"' writed.")
	end
end

exportProduces2JSON("fr")
exportProductLink2JSON()

DBInterface.close!(dbConnection)


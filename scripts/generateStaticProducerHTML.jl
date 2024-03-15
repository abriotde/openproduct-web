#!/usr/local/bin/julia --startup=no

import JSON, OteraEngine, MySQL
SCRIPT_NAME = "generateStaticProducerHTML"
DEBUG=true

include("../../openproduct-docs/sources/OpenProductProducer.jl")

TemplateProducerPage = missing

function generateStaticProducerPage(filepath::String, producer::MySQL.TextRow)
	if ismissing(TemplateProducerPage)
		global TemplateProducerPage = OteraEngine.Template("./templateProducerPage.html")
	end
	file = open(filepath, "w") do file
		dictionary = Dict{String, String}(
			string(key) => string(producer[key]) for key in propertynames(producer)
		)
		write(file, TemplateProducerPage(init=dictionary))
	end
end
function generateStaticProducerPages(webrootpath::String, webpath::String; useCache=false)
	if DEBUG; println("generateStaticProducerPages(",webrootpath,",",webpath,")"); end
	mindate = "2000-01-01 00:00:00"
	if useCache
		mindate = Dates.format(op_getPreviousScriptTime(start), DATEFORMAT_MYSQL)
	end
	sql = "Select if(lastUpdateDate>='"*mindate*"', 0, 1) ok, id, latitude lat, longitude lng, name,
			COALESCE(`text`, shortDescription) text, wikiTitle wiki,
			shortDescription job,
			concat(address,' ',postCode,' ',city) as address,
			phoneNumber, phoneNumber2,
			if(sendEmail is NULL or sendEmail!='wrongEmail',email,'') as email,
			if(websiteStatus in ('ok','400'), website, '') as website, siret
		FROM producer
		WHERE latitude is not null AND longitude is not null
			AND status in ('actif','unknown','to-check')
		ORDER BY name"
	if DEBUG
		println("SQL:",sql)
	end
	producers = DBInterface.execute(dbConnection, sql)
	weburl = webpath*"/producer_%d.html"
	nb::Int = 0
	nbDone::Int = 0
	producers2 = Dict{Int, String}()
	for producer in producers
		if producer[:ok]==0
			producerFilepath = webrootpath*replace(weburl, "%d"=>string(producer[:id]))
			generateStaticProducerPage(producerFilepath, producer)
			nbDone += 1
			if nbDone%10==0
				print(".")
			end
		end
		# println(" File '"*producerFilepath*"' writed.")
		producers2[producer[:id]] = producer[:name]
		nb += 1
	end
	filepath = webrootpath*webpath*"/index.html"
	page = OteraEngine.Template("./templateProducerDirectory.html")
	file = open(filepath, "w") do file
		write(file, page(init=Dict(
			"producers"=>producers2,
			"weburl"=>weburl
		)))
	end
	println(string(nb)*" producers in file '"*filepath*"' writed (",string(nbDone),").")
end

generateStaticProducerPages("../public","/producers", useCache=false)

op_stop(ok)


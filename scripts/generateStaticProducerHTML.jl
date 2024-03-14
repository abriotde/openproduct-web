#!/usr/local/bin/julia --startup=no

import JSON, OteraEngine, MySQL







include("../../openproduct-docs/sources/OpenProductProducer.jl")


function generateStaticProducerPage(filepath::String, producer::MySQL.TextRow)
	page = OteraEngine.Template("./templateProducerPage.html")
	# producerDB = Dict(propertynames(params) .=> values(params))
	file = open(filepath, "w") do file
		dictionary = Dict{String, String}(
			string(key) => string(producer[key]) for key in propertynames(producer)
		)
		write(file, page(init=dictionary))
	end
end
function generateStaticProducerPages(webrootpath::String, webpath::String)
	println("generateStaticProducerPages(",webrootpath,",",webpath,")")
	sql = "Select id, latitude lat, longitude lng, name,
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
	producers = DBInterface.execute(dbConnection,sql)
	weburl = webpath*"/producer_%d.html"
	nb::Int = 0
	producers2 = Dict{Int, String}()
	for producer in producers
		producerFilepath = webrootpath*replace(weburl, "%d"=>string(producer[:id]))
		generateStaticProducerPage(producerFilepath, producer)
		# println(" File '"*producerFilepath*"' writed.")
		producers2[producer[:id]] = producer[:name]
		print(".")
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
	println(" File '"*filepath*"' writed.")
end

generateStaticProducerPages("../public","/producers")
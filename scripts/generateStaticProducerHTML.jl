#!/usr/local/bin/julia --startup=no

import JSON, OteraEngine, MySQL, Dates, DBInterface
DEBUG=true

include("connect.jl")

TemplateProducerPage = missing

function generateStaticProducerPage(filepath::String, producer::MySQL.TextRow)
	# println("generateStaticProducerPage(",filepath,",",producer,")")
	print(".")
	if ismissing(TemplateProducerPage)
		global TemplateProducerPage = OteraEngine.Template("./templateProducerPage.html")
	end
	file = open(filepath, "w") do file
		dictionary = Dict{String, String}(
			string(key) => string(producer[key]) for key in propertynames(producer)
		)
		wikiName = producer[:wiki]
		if ismissing(wikiName) || isempty(wikiName)
			# On génère le nom wiki à partir du nom producteur
    		wikiName = replace(lowercase(producer[:name]), " "=>"_", "é"=>"e", "è"=>"e", "ê"=>"e"
				,"î"=>"i", "ï"=>"i", "ö"=>"o", "ô"=>"o", "à"=>"a", "ù"=>"u", "'"=>"%27")
		end
		dictionary["wiki"] = wikiName;
		write(file, TemplateProducerPage(init=dictionary))
	end
end
function generateStaticProducerPages(webrootpath::String, webpath::String; useCache=false)
	if DEBUG; println("generateStaticProducerPages(",webrootpath,",",webpath,")"); end
	mindate = "2000-01-01 00:00:00"
	if useCache
		mindate = Dates.format(
			OpenProduct.getPreviousScriptTime(OpenProduct.start, dbConnection),
			OpenProduct.mysql_get_dateformat()
		)
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

generateStaticProducerPages("../public","/producers", useCache=true)

OpenProduct.op_stop(OpenProduct.ok, dbConnection)


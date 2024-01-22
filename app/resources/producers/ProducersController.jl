module ProducersController
	using Genie, Genie.Renderer, Genie.Renderer.Html, Genie.Renderer.Json, SearchLight, OpenproductWeb.Producers
	using GenieAuthentication, Genie.Requests, JSON

	function index()
		html(:producers, :index, producers=rand(Producer))
	end

	function search()
		if isempty(strip(params(:search_producers)))
			redirect(:list_producers)
		end
		producers = find(Producer,
				  SQLWhereExpression("name LIKE ? OR text LIKE ? OR lastname LIKE ?",
									  repeat(['%' * params(:search_producers) * '%'], 3)))
		html(:producers, :index, producers=producers)
	end

	function edit()
		authenticated!()
		id = payload(:producer_id, "")
        if isempty(id)
			html(:producers, :index, producers=rand(Producer))
		end
		if isempty(strip(params(:p, "")))
			producers = find(Producer, SQLWhereExpression("id=?",id))
			for producer in producers
				return html(:producers, :edit, producer=producer)
			end
			html("No result for id="*id)
		else
			serve_static_file("edit_producer.html?p="*id)
		end
	end
	function get()
		authenticated!()
		id = payload(:producer_id, "")
        if isempty(id)
			Genie.Renderer.Json.json(Dict("ok"=>false, "error"=>"No producer_id's parameter."))
		end
		producers = find(Producer, SQLWhereExpression("id=?",id))
		for producer in producers
			println(producer)
			return Genie.Renderer.Json.json(producer)
		end
		Genie.Renderer.Json.json(Dict("ok"=>false, "error"=>"No producer found for producer_id=$id."))
	end

	function save()
		authenticated!()
		id = payload(:producer_id, "")
        if isempty(id)
			html(:producers, :index, producers=rand(Producer))
		end
		producers = find(Producer, SQLWhereExpression("id=?",id))
		for producer in producers
			# TODO : Save the producer
			json = rawpayload()
			if json==nothing
				producer.name = payload(:name, "")
				println("Name:", rawpayload(), ", json:", json)
			else
				println("Json:", json)
				producerVals = json |> JSON.parse
				println(producerVals)
				retVal = Dict("ok"=>true, "vals"=>producerVals)
				producer.firstname = producerVals["firstname"]
				println(producer)
				SearchLight.save(producer)
				return Genie.Renderer.Json.json(retVal)
			end
			SearchLight.save(producer)
			return html(:producers, :edit, producer=producer)
		end
	end

end

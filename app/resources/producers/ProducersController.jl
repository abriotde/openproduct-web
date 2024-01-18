module ProducersController
	using Genie, Genie.Renderer, Genie.Renderer.Html, SearchLight, OpenproductWeb.Producers
	using GenieAuthentication, Genie.Requests

	function index()
		html(:producers, :index, producers=rand(Producer))
	end

	function search()
		isempty(strip(params(:search_producers))) && redirect(:list_producers)

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
		producers = find(Producer, SQLWhereExpression("id=?",id))
		for producer in producers
			return html(:producers, :edit, producer=producer)
		end
		html("No result for id="*id)
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
			producer.name = postpayload(:name, "")
			println("Name:", producer.name)
			SearchLight.save(producer)
			return html(:producers, :edit, producer=producer)
		end
	end

end

module ProducersController
	using Genie, Genie.Renderer, Genie.Renderer.Html, SearchLight, OpenproductWeb.Producers

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


end

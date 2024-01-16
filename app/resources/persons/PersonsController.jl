module PersonsController
	using Genie.Renderer.Html, SearchLight, OpenproductWeb.Person

	function index()
		# "List of association members"
		html(:persons, :index, persons = rand(Person))
	end
end

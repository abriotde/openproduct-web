module PersonsController
	using Genie.Renderer.Html, SearchLight, OpenproductWeb.Persons

	function index()
		# "List of association members"
		html(:persons, :index, persons = all(Person))
	end
end

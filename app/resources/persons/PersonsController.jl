module PersonsController
	using Genie, Genie.Router, Genie.Renderer, Genie.Renderer.Html, SearchLight, OpenproductWeb.Persons, SearchLightMySQL, DBInterface

	function index()
		# "List of association members"
		html(:persons, :index, persons = all(Person))
	end

	function unsubscribe()
		email = params(:email, "")
		token = params(:token, "")
		if !isempty(email) && !isempty(token)
			cnx = SearchLight.Configuration.load() |> SearchLight.connect
			sql = "Update persons set sendEmail=0 
				where email=? and tokenAccess=?"
			query = DBInterface.prepare(cnx, sql)
			res = DBInterface.execute(query, [email, token])
			if res.rows_affected==0
				sql = "Update producer set sendEmail=0
					where email=? and tokenAccess=?"
				query = DBInterface.prepare(cnx, sql)
				res = DBInterface.execute(query, [email, token])
				if res.rows_affected==0
					return html("Aucun changement n'a été éffectué.")
				end
			end
			html("Plus aucun email ne sera envoyé à '"*email*"'")
		else
			html("Missing parameters values")
		end
	end
end

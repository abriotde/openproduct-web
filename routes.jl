using Genie.Router, Genie.Renderer, Genie.Renderer.Html, Genie.Renderer.Json


route("/") do
  serve_static_file("welcome.html")
end

using OpenproductWeb.PersonsController

route("/members", PersonsController.index)

route("/producers", ProducersController.index, named=:list_producers)
route("/producers/search", ProducersController.search, named=:search_producers)

route("/unsubscribe", PersonsController.unsubscribe)


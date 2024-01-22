using Genie.Router, Genie.Renderer, Genie.Renderer.Html, Genie.Renderer.Json


route("/") do
  serve_static_file("index.html")
end

using OpenproductWeb.PersonsController

route("/members", PersonsController.index)

route("/producers", ProducersController.index, named=:list_producers)
route("/producers/search", ProducersController.search, named=:search_producers)
route("/producers/get/:producer_id", ProducersController.get, named=:get_producers) # Return as JSON
route("/producers/edit/:producer_id", ProducersController.edit, named = :edit_producers)
route("/producers/save/:producer_id", ProducersController.save, named = :save_producers, method = POST)

route("/unsubscribe", PersonsController.unsubscribe)



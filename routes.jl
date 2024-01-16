using Genie.Router, Genie.Renderer, Genie.Renderer.Html, Genie.Renderer.Json


route("/") do
  serve_static_file("welcome.html")
end
route("/map") do
  serve_static_file("map.html")
end

route("/hello") do
  html("Hello World")
end

using OpenproductWeb.PersonsController

route("/members", PersonsController.index)


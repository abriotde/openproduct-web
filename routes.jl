using Genie.Router

route("/") do
  serve_static_file("welcome.html")
end
route("/map") do
  serve_static_file("map.html")
end

route("/help") do
  serve_static_file("welcome_julia.html")
end

route("/hello") do
  html("Hello World")
end

(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using OpenproductWeb
# using Pkg; Pkg.add("DBInterface")
const UserApp = OpenproductWeb
OpenproductWeb.main()

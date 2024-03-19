include("../lib/OpenProduct.jl/src/OpenProduct.jl")
# using OpenProduct
dbConnection = OpenProduct.dbConnect("../db/connection.yml")
OpenProduct.op_start(dbConnection)

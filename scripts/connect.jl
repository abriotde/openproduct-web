include("../lib/OpenProduct.jl/src/OpenProduct.jl")
using Memoize
dbConnection = OpenProduct.dbConnect("../db/connection.yml")
@memoize OpenProduct.GetConnection() = OpenProduct.dbConnect("../db/connection.yml")
OpenProduct.op_start(dbConnection)

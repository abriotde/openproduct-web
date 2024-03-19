#!/bin/env julia

######### https://cotesdarmor.fr/actualites/une-carte-pour-consommer-local #############

# import Pkg; Pkg.add("JSON")
# import Pkg; Pkg.add("MySQL")
import JSON, MySQL, DBInterface


sqlInsert = DBInterface.prepare(dbConnection, "Insert ignore into openproduct.producer
 (latitude, longitude, name, website, `shortDescription`, wikiTitle, categories)
 values (?,?,?,?,?,?, ?)")

departement = 22
jsonStr = read("../public/producers_"*string(departement)*".json", String)
producers = JSON.parse(jsonStr)
sep = ";"
NULL_VALUE = ""
regexLink = Regex("<a href='(.*)'>(.*)</a>")

function getVal(dict, key, default_value)
    if haskey(dict, key)
        dict[key]
    else
        default_value
    end

end

# latitude, longitude, name,
#   city, postCode, address,
#   phoneNumber, siret,
#   email, website, `text`, openingHours

for producer in producers
    vals = split.(producer[3],"<p>")
    name = vals[1]
    website = ""
    m=match(regexLink,name)
    if m!==nothing
        name = m[2]
        website = m[1]
    end
    description = replace(vals[2], "</p>"=>"")
    println(string(producer[1])*sep*string(producer[2])*sep*name*sep*description*sep*producer[4]*sep*producer[5])

    DBInterface.execute(sqlInsert, [
            producer[1], producer[2], name,
            website, description, producer[4], producer[5]
        ]
    )

end

OpenProduct.op_stop(OpenProduct.ok ,dbConnection)

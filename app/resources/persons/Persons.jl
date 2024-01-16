module Persons

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Person

@kwdef mutable struct Person <: AbstractModel
	id::DbId = DbId()
	firstname::String = ""
	lastname::String = ""
	email::String = ""
	country::String = "France"
	address::String = ""
	city::String = ""
	phoneNumber::Int = 0
	postcode::Int = 0
	notes::String = ""
	options::String = ""
	producer::Int = 0
	
end

end

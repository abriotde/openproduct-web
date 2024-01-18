module Producers

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Producer

@kwdef mutable struct Producer <: AbstractModel
	id::DbId = DbId()
	latitude::AbstractFloat = 0.0
	longitude::AbstractFloat = 0.0
	producerId::Int = 0
	name::String = ""
	firstname::String = ""
	lastname::String = ""
	city::String = ""
	postCode::Int = 0
	address::String = ""
	phoneNumber::String = ""
	siret::String = ""
	email::String = ""
	website::String = ""
	text::String = ""
	wikiTitle::String = ""
	wikiDefaultTitle::String = ""
	shortDescription::String = ""
	openingHours::String = ""
	categories::String = ""
	noteModeration::String = ""
end

end

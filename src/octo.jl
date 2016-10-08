# module Bukdu

module Octo

export Assoc, combine
include("octo/assoc.jl")

export Changeset, change, default, cast
export validates, validate_length
include("octo/changeset.jl")

export singularize, pluralize
include("octo/natural.jl")

end # module Bukdu.Octo

import .Octo: Assoc

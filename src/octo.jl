# module Bukdu

module Octo

export Assoc, combine
include("octo/assoc.jl")

export Changeset, change, default, cast
export validates, validate_length
include("octo/changeset.jl")

export singularize, pluralize
include("octo/natural.jl")

export Database, Adapter
include("octo/database.jl")

export Repo
include("octo/repo.jl")

export Schema, PrimaryKey, Field, schema, has_many
include("octo/schema.jl")

include("octo/query.jl")

end # module Bukdu.Octo

import .Octo: Assoc

# module Bukdu

module Octo

export Assoc, combine
include("octo/assoc.jl")

export Changeset, change, default, cast
export validates, validate_length
include("octo/changeset.jl")

export singularize, pluralize
include("octo/natural.jl")

export Database, Adapter, disconnect
include("octo/database.jl")

export Schema, PrimaryKey, Field, schema, field, has_many, has_one, belongs_to
include("octo/schema.jl")

export Query
include("octo/query.jl")

export SQL
include("octo/sql.jl")

export Repo
include("octo/repo.jl")

include("octo/adapters/base.jl")

end # module Bukdu.Octo

import .Octo: Assoc

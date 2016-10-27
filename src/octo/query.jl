# module Bukdu.Octo

module Query

export Predicate, SubQuery
export from

import ..Repo
import ..Schema
import ..Assoc
import ..Logger
import ..Field
import Base: in, isless, ==, !, &, |

abstract Model

module A

import ..Query
import ..Field

end # module Bukdu.Octo.Query.A

include("query/predicate.jl")
include("query/subquery.jl")

function from(T::Type; kw...)::SubQuery
    subquery(From([T]); kw...)
end

function from(; kw...)::SubQuery
    subquery(From([]); kw...)
end

function type_generate(T::Type)::Type # <: Query.Model
    type_name = T.name.name
    lines = String[]
    fields = Assoc()
    for i in 1:nfields(T)
        push!(fields, (fieldname(T, i), :Field))
    end
    for (typ, vec) in Schema.relations
        for (relation,name,FT) in vec
            if FT==T && :has_many==relation
                push!(fields, (Symbol(lowercase(string(typ.name.name, "_id"))), :Field))
            end
        end
    end
    push!(lines, "type $type_name <: Query.Model")
    for (name,typ) in fields
        push!(lines, "    $name::$typ")
    end
    push!(lines, "end")
    code = join(lines, "\n")
    eval(A, parse(code))
    getfield(A, type_name)
end

function pooling_type(T::Type)::Type # <: Query.Model
    type_name = T.name.name
    isdefined(A, type_name) ? getfield(A, type_name) : type_generate(T)
end

function in(T::Type)::Query.Model
    typ = pooling_type(T)
    typ([Field(typ, name) for name in fieldnames(typ)]...)
end

end # module Bukdu.Octo.Query

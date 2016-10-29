# module Bukdu.Octo

module Query

export Predicate, SubQuery
export ?
export from
export and, or, not_in, is_null, is_not_null, like, not_like, between

import ..Repo
import ..Schema
import ..Assoc
import ..Logger
import ..Field
import Base: in, isless, ==, !, &, |

abstract Model

module A

import ....Octo
import .Octo: Schema, Query, Field

end # module Bukdu.Octo.Query.A

type ?
end

include("query/predicate.jl")
include("query/subquery.jl")

function from(; kw...)::SubQuery
    subquery(From([]); kw...)
end

function from{M<:Query.Model}(::M; kw...)::SubQuery
    subquery(From([M]); kw...)
end

function from(T::Type; kw...)::SubQuery
    m = in(T)
    subquery(From([typeof(m)]); kw...)
end

function type_generate(T::Type)::Type # <: Query.Model
    type_name = T.name.name
    type_name_uuid = replace(string(type_name, '_', Base.Random.uuid1()), '-', '_')
    lines = String[]
    fields = Assoc()
    for i in 1:nfields(T)
        push!(fields, (fieldname(T, i), :Field))
    end
    if haskey(Schema.relations, type_name)
        for (relation,name,FT) in Schema.relations[type_name]
            if :has_many == relation
            #    push!(fields, (name, Base.Generator.name))
            elseif :belongs_to == relation
                push!(fields, (Symbol("$(name)_id"), :Field))
            else # :has_one
            #    push!(fields, (name, FT))
            end
        end
    end
    push!(lines, "type $type_name_uuid <: Query.Model")
    for (name,typ) in fields
        push!(lines, "    $name::$typ")
    end
    push!(lines, "end")
    code = join(lines, "\n")
    # Logger.info("code", code)
    eval(A, parse(code))
    table_name = Schema.table_name(T)
    code = "Query.table_name(::Type{$type_name_uuid}) = $(repr(table_name))"
    eval(A, parse(code))
    eval(A, parse("$type_name = $type_name_uuid"))
    getfield(A, type_name)
end

function table_name
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

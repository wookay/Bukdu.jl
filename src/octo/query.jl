# module Bukdu.Octo

module Query

export Predicate, SubQuery, InsertQuery
export from
export and, or, not_in, is_null, is_not_null, like, not_like, between, exists, not_exists
export asc, desc
export ?

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
include("query/changequery.jl")

models = Dict{Type, Type}() # {Query.Model, Type}

function from(; kw...)::SubQuery
    subquery(From(Set{Type}([])); kw...)
end

function from{M<:Query.Model}(::M; kw...)::SubQuery
    subquery(From(Set{Type}([M])); kw...)
end

function from(T::Type; kw...)::SubQuery
    from(in(T); kw...)
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
    #Logger.info("code", code)
    eval(A, parse(code))
    eval(A, parse("$type_name = $type_name_uuid"))
    model = getfield(A, type_name)
    models[model] = T
    model
end

function table_name{M<:Query.Model}(::Type{M})::String
    Schema.table_name(models[M])
end

function table_name(T::Type)::String
    Schema.table_name(T)
end

function pooling_model(T::Type)::Type # <: Query.Model
    type_name = T.name.name
    isdefined(A, type_name) ? getfield(A, type_name) : type_generate(T)
end

function in(T::Type)::Query.Model
    model = pooling_model(T)
    model(map(fieldnames(model)) do name
        Field(T, name)
    end...)
end

end # module Bukdu.Octo.Query

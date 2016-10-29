# module Bukdu.Octo.Database

import .Bukdu.Octo
import .Octo.Database: Adapter, reset
import .Octo.Repo: insert
import .Octo.Query
import .Octo.Query: From, Select, Predicate, SubQuery, Parameter, statement
import .Octo.Query: and, or, between
import .Octo.Query: in, is_null, like
import .Octo.Query: not_in, is_not_null, not_like
import .Octo.Schema
isdefined(Base, :Iterators) && import Base.Iterators: Filter

dict = Dict()

function reset(::Type{Adapter{Dict}})
    empty!(dict)
end

function get(::Type{Adapter{Dict}}, T::Type, id::Int)
    t = in(T)
    subquery = Query.from(select= *, where= t.id==id)
    record = dict[T][id]
end

function insert(::Type{Adapter{Dict}}, T::Type; kw...)
    typ = Schema.pooling_type(T)
    assoc = Assoc(kw)
    !haskey(dict, T) && merge!(dict, Dict(T=>Dict()))
    id = length(dict[T]) + 1
    assoc[:id] = id
    fields = map(fieldnames(typ)) do name
        if haskey(assoc, name)
            assoc[name]
        else
            ft = fieldtype(typ, name)
            if ft <: Base.Generator
                f(c) = c.user_id == id
                Base.Generator(f, Filter(f, 0))
            else
                default(ft)
            end
        end
    end
    dict[T][id] = typ(fields...)
end

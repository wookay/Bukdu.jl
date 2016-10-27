# module Bukdu.Octo.Database

import .Bukdu.Octo
import .Octo.Database: Adapter, reset
import .Octo.Repo: insert
import .Octo.Query
import .Octo.Query: From, Predicate, SubQuery, in, statement
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

function select_clause(select)::String
    string("select", " ", select)
end

function from_clause(from::From)::String
    tables = from.tables
    list = Vector{String}()
    for table in tables
        table_name = Query.table_name(table)
        alias = Query.table_alias_name(tables, table)
        push!(list, string(table_name, " as ", alias))
    end
    string("from", " ", join(list, ", "))
end

function normalize(from::From, field::Field)::String
    alias = Query.table_alias_name(from.tables, field.typ)
    string(alias, '.', field.name)
end

function normalize(from::From, value::Any)::String
    string(value)
end

function normalize(from::From, pred::Predicate)::String
    l = normalize(from, pred.first)
    r = normalize(from, pred.second)
    string(l, ' ', pred.f, ' ', r)
end

function where_clause(from::From, pred::Predicate)::String
    string("where", " ", normalize(from, pred))
end

function statement(::Type{Adapter{Dict}}, sub::SubQuery)::String
    select = select_clause(sub.select)
    from = from_clause(sub.from)
    where = where_clause(sub.from, sub.where)
    clauses = Vector{String}()
    for x in [select, from, where]
        !isempty(x) && push!(clauses, x)
    end
    join(clauses, ' ')
end

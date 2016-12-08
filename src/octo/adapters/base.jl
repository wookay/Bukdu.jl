# module Bukdu.Octo

module LoadAdapterBase

import ..Database: Adapter
import .Adapter: AdapterBase
import ..Query
import .Query: Select, From, Join, Predicate, SubQuery, InsertQuery, UpdateQuery, DeleteQuery
import .Query: statement, and, or, between, column_phrase_type
import .Query: in, is_null, like, exists
import .Query: not_in, is_not_null, not_like, not_exists
import .Query: order_not_specified, asc, desc, count
import ..Schema
import .Schema: Field, ColumnPhrase, ComponentQuery
import ..Logger
import Base: reset

type AdapterHandleError
    message
end

include("base/subquery.jl")
include("base/changequery.jl")
include("base/componentquery.jl")

function check_adapter_handle(adapter::AdapterBase) # throw AdapterHandleError
    isa(adapter.handle, Void) && throw(AdapterHandleError(""))
end

function reset(::AdapterBase)
    empty!(Query.models)
    empty!(Query.origin_types)
end

function normalize(adapter::AdapterBase, from::From, field::Field)::String
    table = field.typ
    alias = Query.schema_table_alias_name(collect(from.tables), field.typ)
    name = haskey(field.options, :column_name) ? field.options[:column_name] : field.name
    string(alias, '.', name)
end

function normalize(adapter::AdapterBase, from::From, vec::Vector{Field})::String
    join(map(field -> normalize(adapter, from, field), vec), ", ")
end

function normalize(adapter::AdapterBase, from::From, tup::Tuple)::String
    join(map(field -> normalize(adapter, from, field), tup), ", ")
end

function normalize(adapter::AdapterBase, from::From, sub::SubQuery)::String
    second_tables = sub.from.tables
    sub.from.tables = setdiff(second_tables, from.tables)
    statement(adapter, sub)
end

function normalize(adapter::AdapterBase, from::From, param::Type{Query.?})::String
    normalize(param)
end

function normalize(adapter::AdapterBase, from::From, value::Any)::Union{Void,String}
    normalize(value)
end

function normalize(param::Type{Query.?})::String
    "?"
end

function normalize(s::String)::String
    string("'", s, "'")
end

function normalize(a::Any)::String
    string(a)
end

function normalize(::Void)::Void
    nothing
end

function normalize(adapter::AdapterBase, from::From, pred::Predicate)::String
    function manipulize(from, pred)
        l = normalize(adapter, from, pred.first)
        r = isa(pred.second, Void) ? nothing : normalize(adapter, from, pred.second)
        if (==) == pred.op
            op = "="
        elseif and == pred.op
            op = uppercase("and")
        elseif or == pred.op
            op = uppercase("or")
        elseif pred.op in [in, exists]
            op = uppercase(string(Base.function_name(pred.op)))
            if isa(pred.second, SubQuery)
                r = enclosed(adapter, normalize(adapter, from, pred.second))
            else
                r = enclosed(adapter, normalize.(pred.second))
            end
        elseif is_null == pred.op
            op = uppercase("is null")
        elseif between == pred.op
            op = string(uppercase("between"), ' ', pred.second.start, ' ', uppercase("and"))
            r = pred.second.stop
        elseif pred.op in [asc, desc, like]
            op = uppercase(string(Base.function_name(pred.op)))
        elseif count == pred.op
            op = string(uppercase("count"), enclosed(adapter, normalize(adapter, from, pred.second)))
            r = nothing
        elseif order_not_specified == pred.op
            op = nothing
        else
            op = pred.op
        end
        (l, op, r)
    end
    (l, op, r) = manipulize(from, pred)
    if (!) == pred.not
        if (>) == pred.op
            op = <=
        elseif (<) == pred.op
            op = >=
        elseif (==) == pred.op
            op = string(pred.not, '=')
        elseif (in) == pred.op
            op = string(uppercase("not"), ' ', op)
        elseif is_null == pred.op
            op = uppercase("is not null")
        elseif like == pred.op
            op = uppercase("not like")
        elseif exists == pred.op
            op = uppercase("not exists")
        else
            op = string(pred.not, pred.op)
        end
    end
    join((x for x in (l, op, r) if !isa(x, Void)), ' ')
end

function enclosed(adapter::AdapterBase, vec::Vector)::String
    enclosed(adapter, join(vec, ", "))
end

function enclosed(adapter::AdapterBase, s::String)::String
    string('(', s, ')')
end


## SQLite: normalize, table_as_clause
function normalize(adapter::Adapter.SQLite, from::From, field::Field)::String
    name = haskey(field.options, :column_name) ? field.options[:column_name] : field.name
    string(name)
end

function table_as_clause(adapter::Adapter.SQLite, table_name::String, alias::String)::String
    table_name
end

end # module Bukdu.Octo.LoadAdapterBase

import .LoadAdapterBase: statement, normalize, table_as_clause, create_table_column_phrases

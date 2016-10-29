# module Bukdu.Octo

module LoadAdapterBase

import ..Logger
import ..Database.Adapter: AdapterBase
import ..Query
import .Query: From, Select, Predicate, SubQuery, Parameter, statement
import .Query: and, or, between
import .Query: in, is_null, like
import .Query: not_in, is_not_null, not_like
import ..Schema
import .Schema: Field
import Base: reset, connect, all

type AdapterHandleError
    message
end

function check_adapter_handle(adapter::AdapterBase) # throw AdapterHandleError
    isa(adapter.handle, Void) && throw(AdapterHandleError(""))
end

function reset(::AdapterBase)
end

# Query
function statement(adapter::AdapterBase, sub::SubQuery)::String
    select = select_clause(adapter, sub)
    from = from_clause(adapter, sub)
    where = where_clause(adapter, sub)
    clauses = Vector{String}()
    for clause in [select, from, where]
        !isempty(clause) && push!(clauses, clause)
    end
    join(clauses, ' ')
end

function select_clause(adapter::AdapterBase, sub::SubQuery)::String
    name = uppercase(replace(string(sub.select.name), '_', ' '))
    string(name, ' ', normalize(adapter, sub, sub.select.value))
end

function from_clause(adapter::AdapterBase, sub::SubQuery)::String
    tables = sub.from.tables
    list = Vector{String}()
    for table in tables
        table_name = Query.table_name(table)
        alias = Query.table_alias_name(tables, table)
        push!(list, string(table_name, " ", uppercase("as"), " ", alias))
    end
    string(uppercase("from"), " ", join(list, ", "))
end

function normalize(adapter::AdapterBase, sub::SubQuery, field::Field)::String
    alias = Query.table_alias_name(sub.from.tables, field.typ)
    string(alias, '.', field.name)
end

function normalize(adapter::AdapterBase, sub::SubQuery, param::Type{Query.?})
    sub.parameter.index += 1
    "?"
end

function normalize(adapter::AdapterBase, sub::SubQuery, vec::Vector{Field})::String
    join(map(field -> normalize(adapter, sub, field), vec), ", ")
end

function normalize(adapter::AdapterBase, sub::SubQuery, tup::Tuple)::String
    join(map(field -> normalize(adapter, sub, field), tup), ", ")
end

function normalize(adapter::AdapterBase, sub::SubQuery, s::SubQuery)::String
    statement(adapter, s)
end

function normalize(adapter::AdapterBase, sub::SubQuery, value::Any)::String
    normalize(value)
end

function normalize(s::String)::String
    string("'", s, "'")
end

function normalize(a::Any)::String
    string(a)
end

function normalize(adapter::AdapterBase, sub::SubQuery, pred::Predicate)::String
    function manipulize(sub, pred)
        l = normalize(adapter, sub, pred.first)
        r = isa(pred.second, Void) ? nothing : normalize(adapter, sub, pred.second)
        if (==) == pred.f
            f = "="
        elseif and == pred.f
            f = uppercase("and")
        elseif or == pred.f
            f = uppercase("or")
        elseif (in) == pred.f
            f = uppercase("in")
            if isa(pred.second, SubQuery)
                r = string('(', normalize(adapter, sub, pred.second), ')')
            else
                r = string('(', join(normalize.(pred.second), ", "), ')')
            end
        elseif (is_null) == pred.f
            f = uppercase("is null")
        elseif (between) == pred.f
            f = string(uppercase("between"), ' ', pred.second.start, ' ', uppercase("and"))
            r = pred.second.stop
        elseif (like) == pred.f
            f = uppercase("like")
        else
            f = pred.f
        end
        (l, f, r)
    end
    (l, f, r) = manipulize(sub, pred)
    if (!) == pred.iden
        if (>) == pred.f
            f = <=
        elseif (<) == pred.f
            f = >=
        elseif (==) == pred.f
            f = string(pred.iden, "=")
        elseif (in) == pred.f
            f = string(uppercase("not"), ' ', f)
        elseif (is_null) == pred.f
            f = uppercase("is not null")
        elseif (like) == pred.f
            f = uppercase("not like")
        else
            f = string(pred.iden, pred.f)
        end
    end
    string(l, ' ', f, isa(r, Void) ? "" : string(' ', r))
end

function where_clause(adapter::AdapterBase, sub::SubQuery)::String
    predicate = sub.where
    if isnull(predicate)
        ""
    else
        pred = predicate.value
        string(uppercase("where"), " ", normalize(adapter, sub, pred))
    end
end

end # module LoadAdapterBase

import .LoadAdapterBase: statement

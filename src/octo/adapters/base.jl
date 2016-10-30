# module Bukdu.Octo

module LoadAdapterBase

import ..Database.Adapter: AdapterBase
import ..Query
import .Query: From, Select, Predicate, SubQuery, statement
import .Query: and, or, between
import .Query: in, is_null, like, exists
import .Query: not_in, is_not_null, not_like, not_exists
import .Query: order_not_specified, asc, desc
import ..Schema
import .Schema: Field
import ..Logger
import Base: reset, connect, all

type AdapterHandleError
    message
end

function check_adapter_handle(adapter::AdapterBase) # throw AdapterHandleError
    isa(adapter.handle, Void) && throw(AdapterHandleError(""))
end

function reset(::AdapterBase)
    empty!(Query.models)
end

# Query
function statement(adapter::AdapterBase, sub::SubQuery)::String
    select = select_clause(adapter, sub)
    from = from_clause(adapter, sub)
    where = where_clause(adapter, sub)
    order_by = order_by_clause(adapter, sub)
    limit = limit_clause(adapter, sub)
    offset = offset_clause(adapter, sub)
    clauses = Vector{String}()
    for clause in [select, from, where, order_by, limit, offset]
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

function where_clause(adapter::AdapterBase, sub::SubQuery)::String
    predicate = sub.where
    if isnull(predicate)
        ""
    else
        pred = predicate.value
        string(uppercase("where"), " ", normalize(adapter, sub, pred))
    end
end

function order_by_clause(adapter::AdapterBase, sub::SubQuery)::String
    order = sub.order_by
    if isnull(order)
        ""
    else
        orders = map(order.value.fields) do pred
            normalize(adapter, sub, pred)
        end
        string(uppercase("order by"), " ", join(orders, ", "))
    end
end

function limit_clause(adapter::AdapterBase, sub::SubQuery)::String
    predicate = sub.limit
    if isnull(predicate)
        ""
    else
        pred = predicate.value
        string(uppercase("limit"), " ", normalize(adapter, sub, pred))
    end
end

function offset_clause(adapter::AdapterBase, sub::SubQuery)::String
    predicate = sub.offset
    if isnull(predicate)
        ""
    else
        pred = predicate.value
        string(uppercase("offset"), " ", normalize(adapter, sub, pred))
    end
end

function normalize(adapter::AdapterBase, sub::SubQuery, field::Field)::String
    alias = Query.table_alias_name(sub.from.tables, field.typ)
    string(alias, '.', field.name)
end

function normalize(adapter::AdapterBase, sub::SubQuery, param::Type{Query.?})
    "?"
end

function normalize(adapter::AdapterBase, sub::SubQuery, vec::Vector{Field})::String
    join(map(field -> normalize(adapter, sub, field), vec), ", ")
end

function normalize(adapter::AdapterBase, sub::SubQuery, tup::Tuple)::String
    join(map(field -> normalize(adapter, sub, field), tup), ", ")
end

function normalize(adapter::AdapterBase, sub::SubQuery, s::SubQuery)::String
    second_tables = s.from.tables
    s.from.tables = setdiff(second_tables, sub.from.tables)
    statement(adapter, s)
end

function normalize(adapter::AdapterBase, sub::SubQuery, value::Any)::Union{Void,String}
    normalize(value)
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
        elseif pred.f in [in, exists]
            f = uppercase(string(Base.function_name(pred.f)))
            if isa(pred.second, SubQuery)
                r = string('(', normalize(adapter, sub, pred.second), ')')
            else
                r = string('(', join(normalize.(pred.second), ", "), ')')
            end
        elseif is_null == pred.f
            f = uppercase("is null")
        elseif between == pred.f
            f = string(uppercase("between"), ' ', pred.second.start, ' ', uppercase("and"))
            r = pred.second.stop
        elseif order_not_specified == pred.f
            f = nothing
        elseif pred.f in [asc, desc, like]
            f = uppercase(string(Base.function_name(pred.f)))
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
        elseif is_null == pred.f
            f = uppercase("is not null")
        elseif like == pred.f
            f = uppercase("not like")
        elseif exists == pred.f
            f = uppercase("not exists")
        else
            f = string(pred.iden, pred.f)
        end
    end
    join((x for x in (l, f, r) if !isa(x, Void)), " ")
end

end # module LoadAdapterBase

import .LoadAdapterBase: statement

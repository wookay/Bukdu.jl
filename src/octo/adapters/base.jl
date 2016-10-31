# module Bukdu.Octo

module LoadAdapterBase

import ..Database: Adapter
import .Adapter: AdapterBase
import ..Query
import .Query: From, Select, Predicate, SubQuery, InsertQuery, UpdateQuery, DeleteQuery
import .Query: statement, and, or, between
import .Query: in, is_null, like, exists
import .Query: not_in, is_not_null, not_like, not_exists
import .Query: order_not_specified, asc, desc
import ..Schema
import .Schema: Field
import ..Logger
import Base: reset

type AdapterHandleError
    message
end

function check_adapter_handle(adapter::AdapterBase) # throw AdapterHandleError
    isa(adapter.handle, Void) && throw(AdapterHandleError(""))
end

function reset(::AdapterBase)
    empty!(Query.models)
end

# SubQuery
function statement(adapter::AdapterBase, sub::SubQuery)::String
    select = select_clause(adapter, sub.from, sub.select)
    from = from_clause(adapter, sub.from)
    where = where_clause(adapter, sub.from, sub.where)
    order_by = order_by_clause(adapter, sub)
    limit = limit_clause(adapter, sub)
    offset = offset_clause(adapter, sub)
    clauses = Vector{String}()
    for clause in [select, from, where, order_by, limit, offset]
        !isempty(clause) && push!(clauses, clause)
    end
    join(clauses, ' ')
end

function select_clause(adapter::AdapterBase, from::From, select::Select)::String
    name = uppercase(replace(string(select.name), '_', ' '))
    if isa(select.value, Vector{Symbol})
        fields = join(select.value, ", ")
    else
        fields = normalize(adapter, from, select.value)
    end
    string(name, ' ', fields)
end

function table_as_clause(adapter::AdapterBase, table::String, alias::String)::String
    string(table, ' ', uppercase("as"), ' ', alias)
end

function table_as_clause(adapter::AdapterBase, from::From)::String
    tables = from.tables
    list = Vector{String}()
    for table in tables
        table_name = Query.table_name(table)
        alias = Query.table_alias_name(collect(tables), table)
        push!(list, table_as_clause(adapter, table_name, alias))
    end
    join(list, ", ")
end

function from_clause(adapter::AdapterBase, from::From)::String
    string(uppercase("from"), ' ', table_as_clause(adapter, from))
end

function where_clause(adapter::AdapterBase, from::From, where::Nullable{Predicate})::String
    if isnull(where)
        ""
    else
        where_clause(adapter, from, where.value)
    end
end

function where_clause(adapter::AdapterBase, from::From, pred::Predicate)::String
    string(uppercase("where"), ' ', normalize(adapter, from, pred))
end

function order_by_clause(adapter::AdapterBase, sub::SubQuery)::String
    order = sub.order_by
    if isnull(order)
        ""
    else
        orders = map(order.value.fields) do pred
            normalize(adapter, sub.from, pred)
        end
        string(uppercase("order by"), ' ', join(orders, ", "))
    end
end

function limit_clause(adapter::AdapterBase, sub::SubQuery)::String
    n = sub.limit
    if isnull(n)
        ""
    else
        string(uppercase("limit"), ' ', normalize(adapter, sub.from, n.value))
    end
end

function offset_clause(adapter::AdapterBase, sub::SubQuery)::String
    n = sub.offset
    if isnull(n)
        ""
    else
        string(uppercase("offset"), ' ', normalize(adapter, sub.from, n.value))
    end
end

function normalize(adapter::AdapterBase, from::From, field::Field)::String
    alias = Query.table_alias_name(collect(from.tables), field.typ)
    string(alias, '.', field.name)
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
        if (==) == pred.f
            f = "="
        elseif and == pred.f
            f = uppercase("and")
        elseif or == pred.f
            f = uppercase("or")
        elseif pred.f in [in, exists]
            f = uppercase(string(Base.function_name(pred.f)))
            if isa(pred.second, SubQuery)
                r = enclosed(adapter, normalize(adapter, from, pred.second))
            else
                r = enclosed(adapter, normalize.(pred.second))
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
    (l, f, r) = manipulize(from, pred)
    if (!) == pred.iden
        if (>) == pred.f
            f = <=
        elseif (<) == pred.f
            f = >=
        elseif (==) == pred.f
            f = string(pred.iden, '=')
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
    join((x for x in (l, f, r) if !isa(x, Void)), ' ')
end

function enclosed(adapter::AdapterBase, vec::Vector)::String
    enclosed(adapter, join(vec, ", "))
end

function enclosed(adapter::AdapterBase, s::String)::String
    string('(', s, ')')
end

# InsertQuery
function statement(adapter::AdapterBase, ins::InsertQuery)::String
    names = enclosed(adapter, keys(ins.fields))
    vals = enclosed(adapter, normalize.(values(ins.fields)))
    string(uppercase("insert"), ' ', uppercase("into"), ' ', ins.table, ' ', names, ' ', uppercase("values"), ' ', vals)
end

# UpdateQuery
function statement(adapter::AdapterBase, up::UpdateQuery)::String
    table_as = table_as_clause(adapter, up.from)
    update = string(uppercase("update"), ' ', table_as, ' ', uppercase("set"))
    vals = join(map(up.fields) do field
        (name, value) = field
        string(name, "=", normalize(value))
    end, ", ")
    where = where_clause(adapter, up.from, up.where)
    clauses = Vector{String}()
    for clause in [update, vals, where]
        !isempty(clause) && push!(clauses, clause)
    end
    join(clauses, ' ')
end

# DeleteQuery
function statement(adapter::AdapterBase, del::DeleteQuery)::String
    delete = string(uppercase("delete"))
    table = string(uppercase("from"), ' ', join(del.table))
    if isempty(del.fields)
        where = ""
    else
        where = string(uppercase("where"), ' ', join(map(del.fields) do field
            (name, value) = field
            string(name, "=", normalize(value))
        end, ", "))
    end
    clauses = Vector{String}()
    for clause in [delete, table, where]
        !isempty(clause) && push!(clauses, clause)
    end
    join(clauses, ' ')
end

## SQLite: normalize, table_as_clause
function normalize(adapter::Adapter.SQLite, from::From, field::Field)::String
    string(field.name)
end

function table_as_clause(adapter::Adapter.SQLite, table::String, alias::String)::String
    table
end

end # module Bukdu.Octo.LoadAdapterBase

import .LoadAdapterBase: statement, normalize, table_as_clause

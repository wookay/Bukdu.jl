# module Bukdu.Octo.LoadAdapterBase

# SubQuery
function statement(adapter::AdapterBase, sub::SubQuery)::String
    select = select_clause(adapter, sub.from, sub.select)
    from = from_clause(adapter, sub.from, sub.join)
    where = where_clause(adapter, sub.from, sub.where)
    group_by = group_by_clause(adapter, sub)
    order_by = order_by_clause(adapter, sub)
    limit = limit_clause(adapter, sub)
    offset = offset_clause(adapter, sub)
    clauses = Vector{String}()
    for clause in [select, from, where, group_by, order_by, limit, offset]
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

function table_as_clause(adapter::AdapterBase, table_name::String, alias::String)::String
    string(table_name, ' ', uppercase("as"), ' ', alias)
end

function table_as_clause(adapter::AdapterBase, from::From)::String
    tables = from.tables
    list = Vector{String}()
    for table in tables
        alias = Query.schema_table_alias_name(collect(tables), table)
        push!(list, table_as_clause(adapter, Query.schema_table_name(table), alias))
    end
    join(list, ", ")
end

function join_clause(adapter::AdapterBase, from::From, join::Join)::String
    name = uppercase(replace(string(join.name), '_', ' '))
    on = normalize(adapter, from, join.on)
    string(name, ' ', table_as_clause(adapter, From([join.table])), ' ', uppercase("on"), ' ', on)
end

function from_clause(adapter::AdapterBase, from::From, join::Nullable{Join})::String
    if isnull(join)
        string(uppercase("from"), ' ', table_as_clause(adapter, from))
    else
        tables = setdiff(from.tables, [join.value.table])
        string(uppercase("from"), ' ', table_as_clause(adapter, From(tables)), ' ', join_clause(adapter, from, join.value))
    end
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

function having_clause(adapter::AdapterBase, from::From, pred::Predicate)::String
    string(uppercase("having"), ' ', normalize(adapter, from, pred))
end

function group_by_clause(adapter::AdapterBase, sub::SubQuery)::String
    group = sub.group_by
    if isnull(group)
        ""
    else
        group_by = group.value
        groups = map(group.value.columns) do field
            normalize(adapter, sub.from, field)
        end
        having = isnull(group_by.having) ? "" : having_clause(adapter, sub.from, group_by.having.value)
        string(uppercase("group by"), ' ', join(groups, ", "), isempty(having) ? "" : string(' ', having))
    end
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

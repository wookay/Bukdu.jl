# module Bukdu.Octo.Query

import ..Database: Adapter, get_adapter

type From
    tables::Vector{Type}
end

type Select
    name::Symbol # :select, :select_distinct
    value::Any
end

type Join
    name::Symbol # :join, ...
    table::Type
    on::Predicate
end

type GroupBy
    columns::Vector{Field}
    having::Nullable{Predicate}
end

type OrderBy
    fields::Vector{Predicate}
end

type SubQuery <: RecordQuery
    select::Select
    from::From
    join::Nullable{Join}
    where::Nullable{Predicate}
    group_by::Nullable{GroupBy}
    order_by::Nullable{OrderBy}
    limit::Nullable{Int}
    offset::Nullable{Int}
end

type SubQueryError
    message
end

function subquery(from::From; kw...)::SubQuery # throw SubQueryError
    opts = Assoc(kw)
    select_names = intersect([:select, :select_distinct], keys(opts))
    if isempty(select_names)
        select = Select(:select, *)
    else
        name = first(select_names)
        value = opts[name]
        select = Select(name, value)
        if isa(value, Field) ||
           isa(value, Tuple) ||
           isa(value, Vector{Field})
            for table in Query.tables(value)
                !in(table, from.tables) && push!(from.tables, table)
            end
        end
    end
    join_names = intersect([:join, :left_join, :left_outer_join, :right_join, :right_outer_join,
                            :full_join, :full_outer_join, :inner_join, :outer_join, :cross_join, :natural_join], keys(opts))
    if isempty(join_names)
        join = Nullable{Join}()
    else
        name = first(join_names)
        table = opts[name]
        join_table = isa(table, Query.Model) ? origin_types[typeof(table)] : table
        on = opts[:on]
        for table in Query.tables(on)
            !in(table, from.tables) && push!(from.tables, table)
        end
        join = Nullable(Join(name, join_table, on))
    end
    where = haskey(opts, :where) ? Nullable(opts[:where]) : Nullable{Predicate}()
    for table in Query.tables(where)
        !in(table, from.tables) && push!(from.tables, table)
    end
    if haskey(opts, :group_by)
        group = opts[:group_by]
        group_tup = isa(group, Tuple) ? group : tuple(group)
        column_tables = Vector{Type}()
        columns = Vector{Field}()
        for field in group_tup
            if isa(field, Field)
                push!(column_tables, field.typ)
            else
                throw(SubQueryError(""))
            end
            push!(columns, field)
        end
        for table in column_tables
            !in(table, from.tables) && push!(from.tables, table)
        end
        if haskey(opts, :having)
            having = Nullable(opts[:having])
        else
            having = Nullable{Predicate}()
        end
        group_by = Nullable(GroupBy(columns, having))
    else
        group_by = Nullable{GroupBy}()
    end
    if haskey(opts, :order_by)
        order = opts[:order_by]
        order_tup = isa(order, Tuple) ? order : tuple(order)
        field_tables = Vector{Type}()
        preds = Vector{Predicate}()
        for field in order_tup
            if isa(field, Field)
                pred = Predicate(order_not_specified, field, nothing)
                push!(field_tables, field.typ)
            elseif isa(field, Predicate)
                pred = field
                push!(field_tables, field.first.typ)
            else
                throw(SubQueryError(""))
            end
            push!(preds, pred)
        end
        for table in field_tables
            !in(table, from.tables) && push!(from.tables, table)
        end
        order_by = Nullable(OrderBy(preds))
    else
        order_by = Nullable{OrderBy}()
    end
    limit = haskey(opts, :limit) ? Nullable(opts[:limit]) : Nullable{Int}()
    offset = haskey(opts, :offset) ? Nullable(opts[:offset]) : Nullable{Int}()
    if isempty(from.tables)
        throw(SubQueryError(""))
    else
        SubQuery(select, from, join, where, group_by, order_by, limit, offset)
    end
end

function statement(subquery::SubQuery, args...)::String # throw NoAdapterError
    adapter = get_adapter()
    statement(adapter, subquery, args...)
end

function tables(tup::Tuple)::Vector{Type}
    collect(map(field -> field.typ, tup))
end

function tables(vec::Vector{Field})::Vector{Type}
    map(field -> field.typ, vec)
end

function tables(field::Field)::Vector{Type}
    [field.typ]
end

function tables(predicate::Nullable{Predicate})::Vector{Type}
    if isnull(predicate)
        Vector{Type}()
    else
        tables(predicate.value)
    end
end

function tables(pred::Predicate)::Vector{Type}
    dict = Dict{Symbol,Type}()
    for x in [pred.first, pred.second]
        if isa(x, Field)
            dict[x.typ.name.name] = x.typ
        end
        if isa(x, Predicate)
            for y in [x.first, x.second]
                if isa(y, Field)
                    dict[y.typ.name.name] = y.typ
                end
            end
        end
    end
    collect(values(dict))
end

in(field::Field, sub::SubQuery)::Predicate = Predicate(in, field, sub)
not_in(field::Field, sub::SubQuery)::Predicate = Predicate(!, in, field, sub)

exists(sub::SubQuery)::Predicate = Predicate(exists, nothing, sub)
not_exists(sub::SubQuery)::Predicate = Predicate(!, exists, nothing, sub)

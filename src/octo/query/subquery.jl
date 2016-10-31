# module Bukdu.Octo.Query

import ..Database: Adapter, get_adapter
import ..pluralize

type From
    tables::Set{Type}
end

type Select
    name::Symbol # :select, :select_distinct
    value::Any
end

type OrderBy
    fields::Vector{Predicate}
end

type SubQuery
    from::From
    select::Select
    where::Nullable{Predicate}
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
    if !isempty(select_names)
        name = first(select_names)
        value = opts[name]
        select = Select(name, value)
        if isa(value, Field) ||
           isa(value, Tuple) ||
           isa(value, Vector{Field})
            for table in Query.tables(value)
                push!(from.tables, table)
            end
        end
    else
        select = Select(:select, *)
    end
    where = haskey(opts, :where) ? Nullable(opts[:where]) : Nullable{Predicate}()
    for table in Query.tables(where)
        push!(from.tables, table)
    end
    if haskey(opts, :order_by)
        order = opts[:order_by] 
        fields = Vector{Predicate}()
        if isa(order, Tuple)
            order_tup = order
        else
            order_tup = tuple(order)
        end
        order_fields = Vector{Type}()
        map(order_tup) do field
            if isa(field, Field)
                pred = Predicate(order_not_specified, field, nothing)
                push!(order_fields, field.typ)
            elseif isa(field, Predicate)
                pred = field
                push!(order_fields, field.first.typ)
            else
                Logger.info("order_by", field)
            end
            push!(fields, pred)
        end
        for table in order_fields
            !in(table, from.tables) && push!(from.tables, table)
        end
        order_by = Nullable(OrderBy(fields))
    else
        order_by = Nullable{OrderBy}()
    end
    limit = haskey(opts, :limit) ? Nullable(opts[:limit]) : Nullable{Int}()
    offset = haskey(opts, :offset) ? Nullable(opts[:offset]) : Nullable{Int}()
    if isempty(from.tables)
        throw(SubQueryError(""))
    else
        SubQuery(from, select, where, order_by, limit, offset)
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

function table_alias_name(tables::Vector{Type}, T::Type)::String
    table_name_chars = first.(Schema.table_name.(tables))
    table_name_char = first(Schema.table_name(T))
    if length(findin(table_name_chars, table_name_char)) > 1
        ind = findfirst(tables, T)
        string(table_name_char, ind)
    else
        string(table_name_char)
    end
end

in(field::Field, sub::SubQuery)::Predicate = Predicate(in, field, sub)
not_in(field::Field, sub::SubQuery)::Predicate = Predicate(!, in, field, sub)

exists(sub::SubQuery)::Predicate = Predicate(exists, nothing, sub)
not_exists(sub::SubQuery)::Predicate = Predicate(!, exists, nothing, sub)

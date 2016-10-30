# module Bukdu.Octo.Query

import .Schema: PrimaryKey

type InsertQuery
    table::String
    fields::Assoc
end

function statement(ins::InsertQuery, args...)::String # throw NoAdapterError
    adapter = get_adapter()
    statement(adapter, ins, args...)
end

function insert(object; kw...)::InsertQuery
    T = typeof(object)
    table = Schema.table_name(T)
    fields = Assoc()
    for name in fieldnames(T)
        if fieldtype(T, name) <: PrimaryKey
        else
            push!(fields, (name, getfield(object, name)))
        end
    end
    InsertQuery(table, fields)
end

function insert(T::Type; kw...)::InsertQuery
    table = Schema.table_name(T)
    fields = Assoc(kw)
    InsertQuery(table, fields)
end

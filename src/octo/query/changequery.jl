# module Bukdu.Octo.Query

import .Schema: PrimaryKey
import ..Changeset

type InsertQuery
    table::String
    fields::Assoc
end

type UpdateQuery
    fields::Assoc
    from::From
    where::Nullable{Predicate}
end

type DeleteQuery
    table::String
    fields::Assoc
end

function statement(ins::InsertQuery, args...)::String # throw NoAdapterError
    adapter = get_adapter()
    statement(adapter, ins, args...)
end

function statement(up::UpdateQuery, args...)::String # throw NoAdapterError
    adapter = get_adapter()
    statement(adapter, up, args...)
end

function statement(del::DeleteQuery, args...)::String # throw NoAdapterError
    adapter = get_adapter()
    statement(adapter, del, args...)
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

function update(changeset::Changeset; where= Nullable{Predicate}())::UpdateQuery
    from = From(Set{Type}([typeof(changeset.model)]))
    UpdateQuery(changeset.changes, from, isnull(where) ? where : Nullable{Predicate}(where))
end

function delete(T::Type; kw...)::DeleteQuery
    table = Schema.table_name(T)
    DeleteQuery(table, Assoc(kw))
end

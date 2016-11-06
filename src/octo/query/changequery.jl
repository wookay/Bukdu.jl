# module Bukdu.Octo.Query

import .Schema: PrimaryKey
import ..Changeset

type InsertQuery <: RecordQuery
    table_name::String
    fields::Assoc
end

type UpdateQuery <: RecordQuery
    fields::Assoc
    from::From
    where::Nullable{Predicate}
end

type DeleteQuery <: RecordQuery
    table_name::String
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
    fields = Assoc()
    for name in fieldnames(T)
        if fieldtype(T, name) <: PrimaryKey
        else
            push!(fields, (name, getfield(object, name)))
        end
    end
    InsertQuery(Query.schema_table_name(T), fields)
end

function insert(T::Type; kw...)::InsertQuery
    fields = Assoc(kw)
    InsertQuery(Query.schema_table_name(T), fields)
end

function update(changeset::Changeset; where= Nullable{Predicate}())::UpdateQuery
    from = From([typeof(changeset.model)])
    UpdateQuery(changeset.changes, from, isnull(where) ? where : Nullable{Predicate}(where))
end

function delete(T::Type; kw...)::DeleteQuery
    DeleteQuery(Query.schema_table_name(T), Assoc(kw))
end

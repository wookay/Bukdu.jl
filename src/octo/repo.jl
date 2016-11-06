# module Bukdu.Octo

module Repo

import ..Octo: Assoc, Changeset, Database, default
import ..SQL
import ..Query
import .Query: Predicate
import ..Migration: MigrationQuery, MigrationSet, MigrationItem, migration_revert_query
import ..Logger
import Base: get

migration_sets = Vector{MigrationSet}()

function convert_result_row(T::Type, row)::T
    result = row
    fields = map(result) do field
        if isa(field, Nullable)
            if isnull(field)
                default(typeof(field).parameters[1])
            else
                field.value
            end
        else
            field
        end
    end
    return T(fields...)
end

function get(T::Type, id)::Union{Void,T}
    adapter = Database.get_adapter()
    model = in(T)
    pred = getfield(model, :id) == id
    columns = fieldnames(T)
    rows = SQL.all(adapter, Query.from(select= columns, where= pred))
    len = length(rows)
    1 == len && return convert_result_row(T, first(rows))
    nothing
end

function get{T}(::Type{Vector{T}}; kw...)::Vector{T}
    adapter = Database.get_adapter()
    model = in(T)
    columns = fieldnames(T)
    sub = Query.from(select= columns; kw...)
    rows = SQL.all(adapter, sub)
    return Vector{T}(map(rows) do row
        convert_result_row(T, row)
    end)
end

function insert(object; kw...)::Bool # throw NoAdapterError
    adapter = Database.get_adapter()
    SQL.insert(adapter, Query.insert(object; kw...))
end

function insert(T::Type; kw...)::Bool # throw NoAdapterError
    adapter = Database.get_adapter()
    SQL.insert(adapter, Query.insert(T; kw...))
end

function update(changeset::Changeset)::Bool # throw NoAdapterError
    T = typeof(changeset.model)
    model = in(T)
    pred = getfield(model, :id) == changeset.model.id.id
    adapter = Database.get_adapter()
    SQL.update(adapter, Query.update(changeset; where= pred))
end

function delete(T::Type, id)::Bool # throw NoAdapterError
    adapter = Database.get_adapter()
    SQL.delete(adapter, Query.delete(T; id=id))
end

function migration(block::Function, version::VersionNumber)
    task = current_task()
    task.storage[:migration] = Vector{MigrationItem}()
    block()
    items = task.storage[:migration]
    delete!(task.storage, :migration)
    up = Vector{MigrationQuery}()
    down = Vector{MigrationQuery}()
    for item in items
        if (+) == item.op
            push!(up, item.query)
        elseif (-) == item.op
            push!(down, item.query)
        elseif (~) == item.op
            push!(up, item.query)
            push!(down, migration_revert_query(item.query))
        end
    end
    set = MigrationSet(version, up, down)
    push!(migration_sets, set)
end

end # module Bukdu.Octo.Repo

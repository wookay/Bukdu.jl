# module Bukdu.Octo

module Repo

import ..SQL
import ..Query
import .Query: Predicate
import ..Octo: Assoc, Changeset, default
import ..Logger
import Base: get

function convert_result_row(T::Type, row)::T
    result = row[1]
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
    model = in(T)
    pred = getfield(model, :id) == id
    columns = fieldnames(T)
    rows = SQL.all(Query.from(select= columns, where= pred))
    len = length(rows)
    1 == len && return convert_result_row(T, first(rows))
    nothing
end

function get{T}(::Type{Vector{T}}; kw...)::Vector{T}
    model = in(T)
    columns = fieldnames(T)
    sub = Query.from(select= columns; kw...)
    rows = SQL.all(sub)
    return Vector{T}(map(rows) do row
        convert_result_row(T, row)
    end)
end

function insert(object; kw...)::Bool # throw NoAdapterError
    SQL.insert(Query.insert(object; kw...))
end

function insert(T::Type; kw...)::Bool # throw NoAdapterError
    SQL.insert(Query.insert(T; kw...))
end

function update(changeset::Changeset)::Bool # throw NoAdapterError
    T = typeof(changeset.model)
    model = in(T)
    pred = getfield(model, :id) == changeset.model.id.id
    SQL.update(Query.update(changeset; where= pred))
end

function delete(T::Type, id)::Bool # throw NoAdapterError
    SQL.delete(Query.delete(T; id=id))
end

end # module Bukdu.Octo.Repo

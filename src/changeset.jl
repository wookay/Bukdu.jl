# module Bukdu

export Changeset

struct Changeset
    model::Type
    changes::NT where {NT<:NamedTuple}
    Changeset(model, changes = NamedTuple()) = new(model, changes)
end

# module Bukdu

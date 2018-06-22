# module Bukdu

export Changeset

"""
    Changeset

Used with `HTML5.Form.change`.
"""
mutable struct Changeset
    model::Type
    changes::NT where {NT<:NamedTuple}
    Changeset(model, changes = NamedTuple()) = new(model, changes)
end

# module Bukdu

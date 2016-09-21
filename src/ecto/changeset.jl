# module Bukdu.Ecto

default(T::Type, ::Type{String}) = ""
default(T::Type, ::Type{Int}) = 0

function default(T::Type)::T
    fields = fieldtype.(T,fieldnames(T))
    T(default.(T, fields)...)
end


type Changeset
    changes
end

function change(t; kw...)#::Changeset
    t
end

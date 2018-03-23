# module Bukdu

struct Assoc
    __bukdu_assoc::Dict{String, String}
end

function Base.getindex(assoc::Assoc, key::String)
    if haskey(assoc.__bukdu_assoc, key)
        getindex(assoc.__bukdu_assoc, key)
    else
        string()
    end
end

function Base.getindex(assoc::Assoc, key::Symbol)
    getindex(assoc, String(key))
end

function Base.getproperty(assoc::Assoc, prop::Symbol)
    if :__bukdu_assoc == prop
        getfield(assoc, prop)
    else
        getindex(assoc, String(prop))
    end
end

for f in (:keys, :values, :pairs, :length, :isempty, :empty!)
    @eval begin
        (Base.$f)(assoc::Assoc) = $f(assoc.__bukdu_assoc)
    end
end
Base.show(io::IO, mime::MIME"text/plain", assoc::Assoc) = show(io, mime, assoc.__bukdu_assoc)

import JSON2
JSON2.write(io::IO, assoc::Assoc) = JSON2.write(io, assoc.__bukdu_assoc)

# module Bukdu

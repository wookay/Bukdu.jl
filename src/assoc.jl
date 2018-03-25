# module Bukdu

export Assoc

struct Assoc
    __bukdu_assoc::Dict{String, String}
end
Assoc(pair::Pair) = Assoc(Dict(pair))
Assoc(pairs...) = Assoc(Dict(pairs...))

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

function Base.show(io::IO, mime::MIME"text/plain", assoc::Assoc)
    body = join(assoc.__bukdu_assoc, ", ")
    println(io, Assoc, '(', body, ')')
end

import JSON2
JSON2.write(io::IO, assoc::Assoc) = JSON2.write(io, assoc.__bukdu_assoc)

# module Bukdu

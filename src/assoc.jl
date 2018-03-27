# module Bukdu

export Assoc

"""
    Assoc
"""
struct Assoc
    __bukdu_assoc::Vector{Pair{String,String}}
end
Assoc(pair::Pair) = Assoc([pair])
Assoc(ps...) = Assoc(collect(ps))

function Base.getindex(assoc::Assoc, key::String)::String
    for (k, v) in assoc.__bukdu_assoc
        k == key && return v
    end
    string()
end

function Base.getindex(assoc::Assoc, key::Symbol)::String
    getindex(assoc, String(key))
end

function Base.setindex!(assoc::Assoc, value::String, key::Symbol)
    setindex!(assoc, value, String(key))
end

function Base.setindex!(assoc::Assoc, value::String, key::String)
    ind = coalesce(findfirst(isequal(key), keys(assoc)), 0)
    if ind > 0
        assoc.__bukdu_assoc[ind] = Pair(key, value)
    else
        push!(assoc, Pair(key, value))
    end
end

function Base.getproperty(assoc::Assoc, prop::Symbol)
    if :__bukdu_assoc == prop
        getfield(assoc, prop)
    else
        getindex(assoc, String(prop))
    end
end

function Base.length(assoc::Assoc)::Bool
    length(assoc.__bukdu_assoc)
end

function Base.isempty(assoc::Assoc)::Bool
    isempty(assoc.__bukdu_assoc)
end

function Base.empty!(assoc::Assoc)
    empty!(assoc.__bukdu_assoc)
end

function haskey(assoc::Assoc, key::String)::Bool
    key in keys(assoc)
end

function haskey(assoc::Assoc, key::Symbol)::Bool
    String(key) in keys(assoc)
end

function Base.keys(assoc::Assoc)::Vector{String}
    getindex.(assoc.__bukdu_assoc, 1)
end

function Base.values(assoc::Assoc)::Vector{String}
    getindex.(assoc.__bukdu_assoc, 2)
end

function Base.pairs(assoc::Assoc)::Base.Iterators.Pairs
    pairs(assoc.__bukdu_assoc)
end

function Base.start(assoc::Assoc)
    start(assoc.__bukdu_assoc)
end

function Base.next(assoc::Assoc, i::Int)
    next(assoc.__bukdu_assoc, i)
end

function Base.done(assoc::Assoc, i::Int)
    done(assoc.__bukdu_assoc, i)
end

function Base.push!(assoc::Assoc, kv::Pair{String,String})
    push!(assoc.__bukdu_assoc, kv)
end

function Base.get(assoc::Assoc, key::Symbol, value::Any)
    if haskey(assoc, key)
        v = assoc[key]
        value isa String ? v : parse(typeof(value), v)
    else
        value
    end
end

function Base.merge(ps::T...)::T where {T <: Vector{Pair{String,String}}}
    assoc = Assoc()
    for p in ps
        for (k, v) in p
            assoc[k] = v
        end
    end
    assoc.__bukdu_assoc
end

function Base.show(io::IO, mime::MIME"text/plain", assoc::Assoc)
    body = join(assoc.__bukdu_assoc, ", ")
    println(io, Assoc, '(', body, ')')
end

import JSON2
JSON2.write(io::IO, assoc::Assoc) = JSON2.write(io, assoc.__bukdu_assoc)

# module Bukdu

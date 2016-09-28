# module Bukdu.Octo

import ..Bukdu

export Assoc

import Base: ==

type Assoc
    vector::Vector{Tuple{Symbol,Any}}
    Assoc(; kw...) = new(Vector(kw))
    Assoc(vector) = new(vector)
    function Assoc(dict::Dict{AbstractString,AbstractString})
        new([(Symbol(k),v) for (k,v) in dict])
    end
    function Assoc(dict::Dict{String,Any})
        new([(Symbol(k),v) for (k,v) in dict])
    end
end

function Base.getindex(assoc::Assoc, key::Symbol)
    for (k,v) in assoc.vector
        k==key && return v
    end
    throw(KeyError("key $key not found"))
end

function Base.getindex(assoc::Assoc, key::String)
    getindex(assoc, Symbol(key))
end

Base.push!(assoc::Assoc, tup::Tuple{Symbol,Any}) = push!(assoc.vector, tup)

Base.keys(assoc::Assoc) = map(first, assoc.vector)
Base.values(assoc::Assoc) = map(last, assoc.vector)
Base.haskey(assoc::Assoc, key::Symbol) = key in keys(assoc)
Base.haskey(assoc::Assoc, key::String) = haskey(assoc, Symbol(key))

Base.length(assoc::Assoc) = length(assoc.vector)
Base.start(assoc::Assoc) = start(assoc.vector)
Base.next(assoc::Assoc, i::Int) = next(assoc.vector, i)
Base.done(assoc::Assoc, i::Int) = done(assoc.vector, i)

Base.isempty(assoc::Assoc) = isempty(assoc.vector)
Base.empty!(assoc::Assoc) = empty!(assoc.vector)

function Base.setindex!(assoc::Assoc, value::Any, key::Symbol)
    if haskey(assoc, key)
        assoc.vector = map((k,v)->k==key ? value : v, assoc.vector)
    else
        push!(assoc, (key,value))
    end
end

function Base.merge!(lhs::Assoc, rhs::Assoc)
    lkeys = keys(lhs)
    for (rk,rv) in rhs
        if rk in lkeys
            lhs.vector[findn(lkeys,rk)] = rv
        else
            push!(lhs.vector, (rk,rv))
        end
    end
    lhs
end

function ==(lhs::Assoc, rhs::Assoc)
    ==(lhs.vector, rhs.vector)
end

function Base.setdiff(lhs::Assoc, rhs::Assoc)::Assoc
    diffs = setdiff(lhs.vector, rhs.vector)
    vec = Vector()
    for x in lhs.vector
        eq = false
        for v in rhs.vector
            if ==(x, v)
                eq = true
                break
            end
        end
        if !eq
            push!(vec, x)
        end
    end
    Assoc(vec)
end

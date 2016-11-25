# module Bukdu.Octo

import Base: ==
import ..Logger

type Assoc
    vector::Vector{Tuple{Symbol,Any}}
    Assoc(; kw...) = new(Vector(kw))
    function Assoc(dict::Dict{AbstractString,AbstractString})
        new([(Symbol(k),v) for (k,v) in dict])
    end
    function Assoc(dict::Dict{String,Any})
        new([(Symbol(k),v) for (k,v) in dict])
    end
    function Assoc(dict::Dict{Symbol,Any})
        new([(k,v) for (k,v) in dict])
    end
    function Assoc(tup::Tuple)
        new([(k,v) for (k,v) in tup])
    end
    function Assoc(vector::Vector)
        new(vector)
    end
    function Assoc(assoc::Assoc)
        assoc
    end
end

function Base.get(assoc::Assoc, key::Symbol, defvalue::Any)
    haskey(assoc, key) ? getindex(assoc, key) : defvalue
end

function Base.get(assoc::Assoc, key::String, defvalue::Any)
    get(assoc, Symbol(key), defvalue)
end

function Base.getindex(assoc::Assoc, key::Symbol) # throw KeyError
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
    ind = findfirst(keys(assoc), key)
    if ind > 0
        assoc.vector[ind] = (key, value)
    else
        push!(assoc, (key, value))
    end
end

function Base.merge(lhs::Assoc, dict::Dict{Symbol,Any})
    merge(lhs, Assoc(dict))
end

function Base.merge(lhs::Assoc, rhs::Assoc)
    assoc = Assoc()
    for (lk,lv) in lhs
        assoc[lk] = lv
    end
    for (rk,rv) in rhs
        assoc[rk] = rv
    end
    assoc
end

function Base.merge!(lhs::Assoc, rhs::Assoc)
    for (rk,rv) in rhs
        lhs[rk] = rv
    end
    lhs
end

function Base.delete!(assoc::Assoc, key::Symbol)
    ind = findfirst(keys(assoc), key)
    if ind > 0
        deleteat!(assoc.vector, ind)
    end
    assoc
end

function combine(T::Type, rhs::Assoc, key::Symbol)
    assoc = Assoc()
    vec = T()
    for (rk,rv) in rhs
        if key==rk
            eltyp = eltype(T)
            push!(vec, isa(rv, eltyp) ? rv : parse(eltyp, rv))
        else
            push!(assoc, (rk,rv))
        end
    end
    assoc[key] = vec
    assoc
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

function Base.show(stream::IO, mime::MIME"text/html", assoc::Assoc)
    strong(x) = "<strong>$x</strong>"
    for (k,v) in assoc
        if mimewritable(mime, (k,v))
            show(stream, mime, (k,v))
        else
            write(stream, string("(", strong(repr(k)), ", ", strong(repr(v)), ")"))
        end
        write(stream, "\n")
    end
end

function Base.copy(assoc::Assoc)
    Assoc(copy(assoc.vector))
end

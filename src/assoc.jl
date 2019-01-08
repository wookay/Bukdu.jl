# module Bukdu

export Assoc

"""
    Assoc
"""
struct Assoc
    __bukdu_assoc::Vector{Pair{String,Any}}
end
Assoc(pair::Pair{String,T}) where T = Assoc(Pair{String,Any}[pair])
Assoc(ps...) = Assoc(collect(ps))

function Base.getindex(assoc::Assoc, key::Symbol)
    getindex(assoc, String(key))
end

function Base.setindex!(assoc::Assoc, value, key::Symbol)
    setindex!(assoc, value, String(key))
end

function Base.setindex!(assoc::Assoc, value, key::String)
    ind = something(findfirst(isequal(key), keys(assoc)), 0)
    if ind > 0
        assoc.__bukdu_assoc[ind] = Pair{String,Any}(key, value)
    else
        push!(assoc, Pair{String,Any}(key, value))
    end
end

function Base.getindex(assoc::Assoc, key::String)
    for (k, v) in assoc.__bukdu_assoc
        k == key && return v
    end
    nothing
end

function Base.getproperty(assoc::Assoc, prop::Symbol)
    if :__bukdu_assoc == prop
        getfield(assoc, prop)
    else
        key = String(prop)
        for (k, v) in assoc.__bukdu_assoc
            k == key && return v
        end
        nothing
    end
end

function Base.length(assoc::Assoc)
    length(assoc.__bukdu_assoc)
end

function Base.isempty(assoc::Assoc)::Bool
    isempty(assoc.__bukdu_assoc)
end

function Base.empty!(assoc::Assoc)
    empty!(assoc.__bukdu_assoc)
end

function Base.haskey(assoc::Assoc, key::String)::Bool
    key in keys(assoc)
end

function Base.haskey(assoc::Assoc, key::Symbol)::Bool
    String(key) in keys(assoc)
end

function Base.keys(assoc::Assoc)::Vector{String}
    getindex.(assoc.__bukdu_assoc, 1)
end

function Base.values(assoc::Assoc)::Vector{Any}
    getindex.(assoc.__bukdu_assoc, 2)
end

function Base.pairs(assoc::Assoc)::Base.Iterators.Pairs
    pairs(assoc.__bukdu_assoc)
end

function Base.push!(assoc::Assoc, kv::Pair{String,Any})
    push!(assoc.__bukdu_assoc, kv)
end

function Base.:(==)(left::Assoc, right::Assoc)::Bool
    left.__bukdu_assoc == right.__bukdu_assoc
end

function Base.get(assoc::Assoc, key::Symbol, value::Any)
    if haskey(assoc, key)
        v = assoc[key]
        if v isa String
            value isa String ? v : parse(typeof(value), v)
        else
            v
        end
    else
        value
    end
end

function Base.merge(ps::T...)::T where {T <: Vector{Pair{String,Any}}}
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

function Base.iterate(assoc::Assoc, v::Int=1)
    iterate(assoc.__bukdu_assoc, v)
end

Base.lastindex(assoc::Assoc) = lastindex(assoc.__bukdu_assoc)

using JSON2
JSON2.write(io::IO, assoc::Assoc) = JSON2.write(io, assoc.__bukdu_assoc)

# module Bukdu

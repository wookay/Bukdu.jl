# module Bukdu

export JSON, JavaScript

struct JSON
end

struct JavaScript
end

"""
    ApplicationController
"""
abstract type ApplicationController end
abstract type AbstractPlug end
abstract type AbstractRender end

"""
    Render <: AbstractRender
"""
struct Render <: AbstractRender
    content_type::String
    body::Vector{UInt8}
end

struct Route
    C::Type{<:ApplicationController}
    action
    path_params::Vector{Pair{String,Any}}
    pipelines::Vector{Function}
end

# module Bukdu

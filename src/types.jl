# module Bukdu

export JSON, JavaScript

# struct JSON
# end

struct JavaScript
end

struct Julia
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
    writer::Function
    data::Any
end

struct Route
    C::Type{<:ApplicationController}
    action
    param_types::Dict{Symbol,DataType}
    path_params::Vector{Pair{String,Any}}
    pipelines::Vector{Function}
end

const RouteResponse = NamedTuple{(:got, :resp, :route), Tuple{Any, Any, Route}}
const RouteAction   = NamedTuple{(:controller, :action)}

# module Bukdu

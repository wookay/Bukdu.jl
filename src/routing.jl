module Routing # Bukdu

import ..Bukdu: ApplicationController, MissingController, Conn, Naming
import ..Bukdu: HTTP

context = Dict{Symbol, Any}(
    :pipe => nothing,
    :routing_tables => Vector{Any}(),
)
routing_pipelines = Dict{Symbol, Vector{Function}}()

struct Route
    C::Type{<:ApplicationController}
    action
    path_params::Vector{Pair{String,String}}
    pipelines::Vector{Function}
end

struct RoutePathError <: Exception
    msg
end

function handle(req::HTTP.Messages.Request)
    uri = HTTP.URI(req.target)
    segments = split(uri.path, '/'; keep=false)
    vals = [Val(Symbol(seg)) for seg in segments]
    route(Val(Symbol(req.method)), vals...)
end

function not_found(c::MissingController)
    "not found"
end

route(args...) = Route(MissingController, not_found, Vector{Pair{String,String}}(), Vector{Function}())

function route_path(args...)
    throw(RoutePathError("path not found"))
end

# idea from HTTP/src/Handlers.jl
function penetrate_segments(segments)
    vals = Expr[]
    path_params = Expr[]
    for seg in segments
        if startswith(seg, ':')
            param = seg[2:end]
            mangled = Symbol(param, :_)
            pair = :(Pair(String($param), String(first(typeof($mangled).parameters))))
            push!(path_params, pair)
            expr = :($mangled::Any)
        else
            expr = :(::Val{Symbol($seg)})
        end
        push!(vals, expr)
    end
    return (vals, path_params)
end

(::Type{Vector{Pair{String,String}}})(p::Pair{String,String}) = [p]

function add_route(verb, url::String, C::Type{<:ApplicationController}, action)
    pipe = context[:pipe]
    pipelines = get(routing_pipelines, pipe, [])
    segments = split(url, '/'; keep=false)
    (vals, path_params) = penetrate_segments(segments) 
    method = Naming.verb_name(verb)
    @eval route(::Val{Symbol($method)}, $(vals...)) = Route($C, $action, Vector{Pair{String,String}}($(path_params...)), $pipelines)
    @eval route_path(::typeof($verb), ::Type{$C}, ::typeof($action)) = $url
    routing_tables = vcat(context[:routing_tables],
        Naming.verb_name(verb), url, nameof(C), nameof(action), (pipe isa Nothing ? "" : repr(pipe)))
    context[:routing_tables] = routing_tables
end

"""
    Routing.empty!()
"""
function empty!()
    context[:pipe] = nothing
    context[:routing_tables] = Vector{Any}()
    Base.empty!(routing_pipelines)
end

end # module Bukdu.Routing

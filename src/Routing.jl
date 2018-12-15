module Routing # Bukdu

using ..Bukdu: ApplicationController, Route
using ..Bukdu.Deps
using ..Bukdu.Naming
using ..Bukdu.System

store = Dict{Symbol, Any}(
    :pipe => nothing,
    :routing_tables => Vector{Any}(),
    :routing_path => Dict{Tuple{Symbol,Symbol,Symbol},String}(),
)
routing_pipelines = Dict{Symbol, Vector{Function}}()

function handle(req::Deps.Request)
    uri = Deps.HTTP.URIs.URI(req.target)
    segments = split(uri.path, '/'; keepempty=false)
    vals = [Val(Symbol(seg)) for seg in segments]
    meth = Symbol(req.method)
    verb = Val(meth === :HEAD ? :GET : meth)
    route(verb, vals...)
end

struct AbstractControllerError <: Exception
    msg
end

(::Type{Vector{Pair{String,String}}})(p::Pair{String,String}...) = [p...]

route(args...) = Route(System.MissingController, System.not_found, Vector{Pair{String,String}}(), Vector{Function}())

# idea from HTTP.jl/src/Handlers.jl
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

function add_route(verb, url::String, C::Type{<:ApplicationController}, action) # throw AbstractControllerError
    isabstracttype(C) && throw(AbstractControllerError(string("use concrete type")))
    pipe = store[:pipe]
    pipelines = get(routing_pipelines, pipe, [])
    segments = split(url, '/'; keepempty=false)
    (vals, path_params) = penetrate_segments(segments) 
    method = Naming.verb_name(verb)
    @eval route(::Val{Symbol($method)}, $(vals...)) = Route($C, $action, Vector{Pair{String,String}}($(path_params...)), $pipelines)
    routing_tables = vcat(store[:routing_tables],
        Naming.verb_name(verb), url, nameof(C), nameof(action), (pipe isa Nothing ? "" : repr(pipe)))
    store[:routing_tables] = routing_tables
    store[:routing_path][Naming.routing_path_key(verb,C,action)] = url
end

function route_path(verb, C::Type{<:ApplicationController}, action)::Union{String,Nothing}
    get(store[:routing_path], Naming.routing_path_key(verb,C,action), nothing)
end

"""
    Routing.empty!()
"""
function empty!()
    store[:pipe] = nothing
    store[:routing_tables] = Vector{Any}()
    store[:routing_path] = Dict{Tuple{Symbol,Symbol,Symbol},String}()
    Base.empty!(routing_pipelines)
    ms = methods(route)
    for m in ms
        Base.delete_method(m)
    end
    @eval route(args...) = Route(System.MissingController, System.not_found, Vector{Pair{String,String}}(), Vector{Function}())
end

end # module Bukdu.Routing

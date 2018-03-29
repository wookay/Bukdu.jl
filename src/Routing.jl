module Routing # Bukdu

import ..Bukdu: ApplicationController, Naming, System, Deps, Route

context = Dict{Symbol, Any}(
    :pipe => nothing,
    :routing_tables => Vector{Any}(),
)
routing_pipelines = Dict{Symbol, Vector{Function}}()

function handle(req::Deps.Request)
    uri = Deps.HTTP.URIs.URI(req.target)
    segments = split(uri.path, '/'; keep=false)
    vals = [Val(Symbol(seg)) for seg in segments]
    route(Val(Symbol(req.method)), vals...)
end

route(args...) = Route(System.MissingController, System.not_found, Vector{Pair{String,String}}(), Vector{Function}())

function route_path(args...)::Nothing
    nothing
end

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
